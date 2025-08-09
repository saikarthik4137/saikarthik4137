from flask import Flask, render_template, request, send_file, url_for
from datetime import datetime
from PIL import Image, ImageDraw, ImageFont
import os

app = Flask(__name__)
OUTPUT_FOLDER = "static"
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

@app.route('/', methods=['GET', 'POST'])
def index():
    result = None
    today = datetime.now().strftime("%d/%m/%Y")
    if request.method == 'POST':
        try:
            weight = float(request.form['weight'])
            wastage = float(request.form['wastage'])
            rate = float(request.form['rate'])
            customer = request.form.get('customer', '').strip()

            product = request.form.get('product', '').strip()

            # Optional: making charge
            making_charge_input = request.form.get('making_charge', '').strip()
            making_charge = float(making_charge_input) if making_charge_input else 0.0

            # Compute wastage and total weight
            wastage_grams = weight * (wastage / 100)
            total_weight = weight + wastage_grams

            # Compute total price
            base_price = total_weight * rate
            total_price = round(base_price + making_charge, 2)

            result = {
                'customer': customer,
                'product': product,
                'weight': weight,
                'wastage': wastage,
                'rate': rate,
                'making_charge': making_charge if making_charge else None,
                'wastage_grams': round(wastage_grams, 2),
                'total_weight': round(total_weight, 2),
                'total_price': f"{total_price:,.2f}"
            }
        except ValueError:
            result = {'error': 'Invalid input'}
    return render_template('index.html', result=result, today=today)

@app.route("/poster-generator", methods=["GET", "POST"])
def poster_generator():
    image_path = None
    if request.method == "POST":
        gold = request.form["gold"]
        silver = request.form["silver"]
        today = datetime.now().strftime("%d/%m/%Y")

        font_path = os.path.join(app.root_path, 'static', 'DejaVuSans-Bold.ttf')
        font_path_regular = os.path.join(app.root_path, 'static', 'DejaVuSans.ttf')

        title_font_small = ImageFont.truetype(font_path, 60)
        text_font = ImageFont.truetype(font_path_regular, 55)
        text_font_small = ImageFont.truetype(font_path_regular, 50)
        bold_large_font = ImageFont.truetype(font_path, 90)
        bold_Medium_font = ImageFont.truetype(font_path, 55)
        bold_subheading_font = ImageFont.truetype(font_path, 60)
        bold_lowerheading_font = ImageFont.truetype(font_path, 60)

        img = Image.new("RGB", (1080, 1530), color=(5, 15, 42))
        draw = ImageDraw.Draw(img)

        # === Add logo on top center ===
        logo_path = os.path.join(app.root_path, 'static', 'wip', 'logo.png')
        if os.path.exists(logo_path):
            logo = Image.open(logo_path).convert("RGBA")
            logo_width, logo_height = 230, 230
            logo = logo.resize((logo_width, logo_height))
            logo_x = (img.width - logo_width) // 2
            logo_y = 30
            img.paste(logo, (logo_x, logo_y), logo)

        # === Exact custom text layout with extra spacing ===
        lines = [
            ("Sri Annamalaiyar", bold_large_font),
            ("Jewels Manufacturers, Trichy", bold_subheading_font),
            ("", None),  # Empty line for space after heading
            ("Contact - 9965241162,8144444588", text_font),
            ("", None),  # Space before date
            (f"Date - {today}", text_font),
            ("", None),  # Empty line for space after heading
            (f"Gold 22 CT - ₹ {gold}/-", bold_large_font),
            (f"Silver - ₹ {silver}/-", bold_large_font),
            ("", None),  # Space before description
            ("Wholesale jewels and Diamonds", bold_Medium_font),
            ("Available here at best prices.", bold_Medium_font),
            ("", None),  # Empty line for space after heading
            ("You're always welcome!!!", text_font),
            ("", None),  # Space before Instagram
            ("Follow us on Instagram:", bold_lowerheading_font),
            ("@sriannamalaiyarjewels", bold_lowerheading_font)
        ]

        y = 280  # Start position below logo (added extra gap after logo)
        for line, font in lines:
            if line == "":  # Skip text drawing for blank lines, just add spacing
                y += 20
                continue
            text_width = draw.textlength(line, font=font)
            draw.text(((1080 - text_width) / 2, y), line, fill="white", font=font)
            y += font.getbbox(line)[3] + 20

        filename = f"poster_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"
        path = os.path.join(OUTPUT_FOLDER, filename)
        img.save(path)
        image_path = path

    return render_template("poster.html", image_path=image_path)

@app.route("/download/<filename>")
def download(filename):
    return send_file(os.path.join(OUTPUT_FOLDER, filename), as_attachment=True)

if __name__ == '__main__':
    app.run(debug=True)
