from flask import Flask, render_template, request
from datetime import datetime

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def index():
    result = None
    today = datetime.now().strftime("%d/%m/%Y")
    if request.method == 'POST':
        try:
            weight = float(request.form['weight'])
            wastage = float(request.form['wastage'])
            rate = float(request.form['rate'])
            wastage_grams = weight * (wastage / 100)
            total_weight = weight + wastage_grams
            total_price = round(total_weight * rate, 2)
            result = {
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

if __name__ == '__main__':
    app.run(debug=True)
