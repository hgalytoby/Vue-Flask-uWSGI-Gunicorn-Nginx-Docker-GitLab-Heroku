from base import app, jsonify, random


@app.route("/api1/", methods=['GET'])
def index():
    return jsonify({'msg': '我是 flask1', 'num': random.randint(1, 100)})


if __name__ == '__main__':
    app.run(host='localhost', port=5000)