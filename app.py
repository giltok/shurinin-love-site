from flask import Flask, render_template_string

app = Flask(__name__)

HTML = """
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<title>Дмитрий Шуринин</title>
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    body {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, #1a0026, #3d0a3a, #4a0e2e, #1a0026);
        background-size: 400% 400%;
        animation: bgMove 15s ease infinite;
        font-family: 'Segoe UI', Tahoma, sans-serif;
        overflow: hidden;
        position: relative;
    }
    @keyframes bgMove {
        0%, 100% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
    }

    /* Плавающие сердечки на фоне */
    .heart {
        position: absolute;
        color: rgba(255, 100, 150, 0.35);
        font-size: 30px;
        animation: rise linear infinite;
        bottom: -50px;
        pointer-events: none;
        filter: blur(1px);
    }
    @keyframes rise {
        0%   { transform: translateY(0) rotate(0deg) scale(1); opacity: 0; }
        10%  { opacity: 1; }
        90%  { opacity: 1; }
        100% { transform: translateY(-110vh) rotate(360deg) scale(1.4); opacity: 0; }
    }

    body::before {
        content: '';
        position: absolute;
        width: 600px;
        height: 600px;
        background: radial-gradient(circle, rgba(255,50,120,0.45), transparent 70%);
        top: -200px;
        right: -200px;
        filter: blur(90px);
        animation: float 9s ease-in-out infinite;
    }
    body::after {
        content: '';
        position: absolute;
        width: 500px;
        height: 500px;
        background: radial-gradient(circle, rgba(200,0,255,0.4), transparent 70%);
        bottom: -200px;
        left: -200px;
        filter: blur(90px);
        animation: float 11s ease-in-out infinite reverse;
    }
    @keyframes float {
        0%, 100% { transform: translate(0, 0); }
        50% { transform: translate(40px, 30px); }
    }

    .card {
        position: relative;
        z-index: 2;
        padding: 60px 70px;
        background: rgba(255, 255, 255, 0.06);
        backdrop-filter: blur(22px);
        border: 1px solid rgba(255, 150, 200, 0.25);
        border-radius: 28px;
        box-shadow: 0 25px 80px rgba(255, 20, 100, 0.25),
                    0 0 40px rgba(255, 100, 180, 0.15);
        text-align: center;
        max-width: 720px;
        animation: fadeIn 1.3s ease-out;
    }
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(40px) scale(0.92); }
        to   { opacity: 1; transform: translateY(0) scale(1); }
    }

    .icon {
        font-size: 3.5rem;
        margin-bottom: 15px;
        display: inline-block;
        animation: heartbeat 1.5s ease-in-out infinite;
        filter: drop-shadow(0 0 25px rgba(255, 50, 120, 0.8));
    }
    @keyframes heartbeat {
        0%, 100% { transform: scale(1); }
        15%      { transform: scale(1.25); }
        30%      { transform: scale(1); }
        45%      { transform: scale(1.2); }
        60%      { transform: scale(1); }
    }

    h1 {
        font-size: 2.9rem;
        letter-spacing: 3px;
        margin-bottom: 22px;
        background: linear-gradient(90deg, #ff2d75, #ff7eb3, #c94bff, #ff2d75);
        background-size: 300% auto;
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        animation: shine 4s linear infinite;
        filter: drop-shadow(0 0 30px rgba(255, 45, 117, 0.5));
    }
    @keyframes shine {
        to { background-position: 300% center; }
    }

    .line {
        width: 110px;
        height: 3px;
        margin: 26px auto;
        background: linear-gradient(90deg, transparent, #ff2d75, #c94bff, transparent);
        border-radius: 3px;
    }

    .love {
        font-size: 1.75rem;
        color: #f0e6ef;
        line-height: 1.7;
        font-weight: 300;
        letter-spacing: 0.5px;
    }
    .love strong {
        color: #ff4d8d;
        font-weight: 700;
        text-shadow: 0 0 20px rgba(255, 77, 141, 0.7);
    }
    .love .hl {
        background: linear-gradient(90deg, #ff4d8d, #c94bff);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        font-weight: 700;
    }

    .sub {
        color: #b89ab6;
        font-size: 0.9rem;
        margin-top: 28px;
        letter-spacing: 3px;
        text-transform: uppercase;
    }
</style>
</head>
<body>

    <!-- Плавающие сердечки -->
    <div class="heart" style="left: 8%;  animation-duration: 9s;  animation-delay: 0s;">❤</div>
    <div class="heart" style="left: 20%; animation-duration: 12s; animation-delay: 2s; font-size: 22px;">♡</div>
    <div class="heart" style="left: 35%; animation-duration: 10s; animation-delay: 4s;">❤</div>
    <div class="heart" style="left: 50%; animation-duration: 14s; animation-delay: 1s; font-size: 18px;">♡</div>
    <div class="heart" style="left: 65%; animation-duration: 11s; animation-delay: 3s;">❤</div>
    <div class="heart" style="left: 78%; animation-duration: 13s; animation-delay: 5s; font-size: 24px;">♡</div>
    <div class="heart" style="left: 90%; animation-duration: 9s;  animation-delay: 2.5s;">❤</div>
    <div class="heart" style="left: 45%; animation-duration: 15s; animation-delay: 6s; font-size: 20px;">❤</div>

    <div class="card">
        <div class="icon">💖</div>
        <h1>ДМИТРИЙ ШУРИНИН</h1>
        <div class="line"></div>
        <p class="love">
            Я вас <span class="hl">очень</span> <strong>люблю</strong> ❤️
        </p>
        <p class="sub">with all my heart</p>
    </div>

</body>
</html>
"""

@app.route("/")
def index():
    return render_template_string(HTML)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)