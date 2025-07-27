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
            wastage_grams = weight * (wastage / 100)
            total_weight = weight + wastage_grams
            total_price = round(total_weight * rate, 2)
            result = {
                'customer': customer,
                'weight': weight,
                'wastage': wastage,
                'rate': rate,
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

        title_font_small = ImageFont.truetype(font_path, 40)
        text_font = ImageFont.truetype(font_path_regular, 35)
        text_font_small = ImageFont.truetype(font_path_regular, 34)
        bold_large_font = ImageFont.truetype(font_path, 70)

        # Create base poster image
        img = Image.new("RGB", (1080, 1080), color=(5, 15, 42))
        draw = ImageDraw.Draw(img)

        # === Add logo on top center ===
        logo_path = os.path.join(app.root_path, 'static', 'wip', 'logo.png')
        if os.path.exists(logo_path):
            logo = Image.open(logo_path).convert("RGBA")
            logo_width, logo_height = 160, 160
            logo = logo.resize((logo_width, logo_height))
            logo_x = (img.width - logo_width) // 2
            logo_y = 30
            img.paste(logo, (logo_x, logo_y), logo)

        emoji_font_path = os.path.join(app.root_path, 'static', 'wip', 'Symbola.ttf')
        emoji_font = ImageFont.truetype(emoji_font_path, 34)

        # Poster text lines
        lines = [
            ("Sri Annamalaiyar Jewels Manufacturers,Trichy", title_font_small),
            ("Contact - 9965241162, 8144444588", text_font),
            (f"Date - {today}", text_font),
            (f"Gold 22 CT - ₹ {gold} /-", bold_large_font),
            (f"Silver - ₹ {silver} /-", bold_large_font),
            ("Wholesale jewels and Diamonds Available here at best prices.", text_font_small),
            ("You're always welcome!!!", text_font),
            ("Follow us on Instagram : @sriannamalaiyarjewels", text_font)
        ]

        y = 220  # Start below the logo
        for line, font in lines:
            text_width = draw.textlength(line, font=font)
            draw.text(((1080 - text_width) / 2, y), line, fill="white", font=font)
            y += font.getbbox(line)[3] + 30

        # Save poster
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
