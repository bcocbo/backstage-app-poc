from flask import Flask, jsonify
from datetime import datetime
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': '¡Hola Mundo desde ${{ values.name }}!',
        'description': '${{ values.description }}',
        'environment': '${{ values.environment }}',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': '${{ values.name }}',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/info')
def info():
    return jsonify({
        'name': '${{ values.name }}',
        'description': '${{ values.description }}',
        'environment': '${{ values.environment }}',
        'language': 'Python',
        'framework': 'Flask',
        'version': '1.0.0'
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    print('=' * 50)
    print(f'🚀 ${{ values.name }} iniciando...')
    print(f'📊 Entorno: ${{ values.environment }}')
    print(f'🌐 Puerto: {port}')
    print(f'✅ Health check: http://localhost:{port}/health')
    print(f'ℹ️  Info: http://localhost:{port}/info')
    print('=' * 50)
    app.run(host='0.0.0.0', port=port, debug=False)
