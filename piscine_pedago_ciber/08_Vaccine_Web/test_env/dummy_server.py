#!/usr/bin/env python3
from flask import Flask, request, render_template_string
import sqlite3
import os

app = Flask(__name__)
DB_PATH = 'test_env/test_vuln.db'

def init_db():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        cursor.execute("DROP TABLE IF EXISTS users")
        cursor.execute("DROP TABLE IF EXISTS secret_data")
        cursor.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, password TEXT)")
        cursor.execute("CREATE TABLE secret_data (id INTEGER PRIMARY KEY, target_name TEXT, info TEXT)")
        cursor.executemany("INSERT INTO users (username, password) VALUES (?, ?)", [
            ('admin', 'super_secret_admin_pass'),
            ('guest', 'guest123')
        ])
        cursor.executemany("INSERT INTO secret_data (target_name, info) VALUES (?, ?)", [
            ('ProjectX', 'Launch date 2026'),
            ('Vaccine', 'SQLi testing suite')
        ])
        conn.commit()

# Plantilla HTML simple para pruebas
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head><title>Test App Vaccine</title></head>
<body>
    <h1>Vuln-App GET</h1>
    <form method="GET" action="/search">
        <input type="text" name="q" placeholder="Search user...">
        <button type="submit">Search</button>
    </form>
    
    <h1>Vuln-App POST</h1>
    <form method="POST" action="/login">
        <input type="text" name="username" placeholder="Username">
        <input type="password" name="password" placeholder="Password">
        <button type="submit">Login</button>
    </form>
    
    <div>
        {% if results %}
            <hr><h3>Resultados:</h3>
            <ul>{% for r in results %}<li>{{ r }}</li>{% endfor %}</ul>
        {% endif %}
        {% if error %}
            <hr><p style="color:red;">Error de Base de Datos: {{ error }}</p>
        {% endif %}
    </div>
</body>
</html>
'''

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/search', methods=['GET'])
def search():
    query = request.args.get('q', '')
    results = []
    error = None
    try:
        with sqlite3.connect(DB_PATH) as conn:
            cursor = conn.cursor()
            # Vulnerabilidad clásica concatenando el input!!
            sql = f"SELECT username FROM users WHERE username = '{query}'"
            cursor.execute(sql)
            results = cursor.fetchall()
    except Exception as e:
        error = str(e)
    
    return render_template_string(HTML_TEMPLATE, results=results, error=error)

@app.route('/login', methods=['POST'])
def login():
    user = request.form.get('username', '')
    pwd = request.form.get('password', '')
    results = []
    error = None
    try:
        with sqlite3.connect(DB_PATH) as conn:
            cursor = conn.cursor()
            # Vulnerabilidad en POST
            sql = f"SELECT id FROM users WHERE username = '{user}' AND password = '{pwd}'"
            cursor.execute(sql)
            results = cursor.fetchall()
            if results:
                results = ["Login Successful! Welcome " + user]
            else:
                results = ["Invalid credentials"]
    except Exception as e:
        error = str(e)
    
    return render_template_string(HTML_TEMPLATE, results=results, error=error)

if __name__ == '__main__':
    init_db()
    print("Iniciando servidor de pruebas vulnerable en http://127.0.0.1:5000")
    app.run(debug=True, port=5000)
