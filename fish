"""
prank_dima.py — пранк для Димы Шуринина (со скримером и звуком)
Запуск: python prank_dima.py
Только стандартная библиотека. Скример-звук генерируется на лету.
"""

import tkinter as tk
import random
import threading
import time
import sys
import os
import wave
import struct
import math
import tempfile

# ---------- Палитра ----------
BG        = "#0b0f14"
PANEL     = "#111821"
BORDER    = "#1f2a37"
NEON      = "#00ffa3"
ALERT     = "#ff3b6b"
TEXT      = "#d7e0ea"
TEXT_DIM  = "#5c6b7a"
FONT_MONO = ("Consolas", 11)
FONT_BIG  = ("Segoe UI", 22, "bold")
FONT_MID  = ("Segoe UI", 13)
FONT_SM   = ("Segoe UI", 10)


# ---------- Звук скримера (генерируется программно) ----------
def generate_scream_wav(path, duration=1.8, rate=44100):
    """Создаёт резкий, но не оглушающий скример-звук."""
    n = int(rate * duration)
    with wave.open(path, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(rate)
        frames = bytearray()
        for i in range(n):
            t = i / rate
            # обёртка (fade-in/out)
            if t < 0.04:
                env = t / 0.04
            elif t > duration - 0.3:
                env = (duration - t) / 0.3
            else:
                env = 1.0
            # "взлетающая" частота + диссонанс
            sweep = 220 + 900 * (t / duration)
            s  = 0.40 * math.sin(2 * math.pi * sweep * t)
            s += 0.25 * math.sin(2 * math.pi * sweep * 1.47 * t)
            s += 0.20 * math.sin(2 * math.pi * sweep * 2.31 * t)
            s += 0.20 * (random.random() * 2 - 1)  # шум
            s *= env * 0.72                          # не на полную амплитуду
            s = max(-1.0, min(1.0, s))
            frames += struct.pack('<h', int(s * 32000))
        wf.writeframes(bytes(frames))


def play_sound(path):
    try:
        if sys.platform == 'win32':
            import winsound
            winsound.PlaySound(path, winsound.SND_FILENAME | winsound.SND_ASYNC)
        elif sys.platform == 'darwin':
            import subprocess
            subprocess.Popen(['afplay', path],
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            import subprocess
            subprocess.Popen(['aplay', '-q', path],
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass


def stop_sound():
    try:
        if sys.platform == 'win32':
            import winsound
            winsound.PlaySound(None, winsound.SND_PURGE)
    except Exception:
        pass


# ---------- Фейковые "хакерские" строки ----------
FAKE_HACK_LINES = [
    "[+] Подключение к устройству ...",
    "[+] Обход firewall ... OK",
    "[+] Получение MAC-адреса: 3C:7A:9F:{:02X}:{:02X}:{:02X}",
    "[+] Сканирование портов 22, 80, 443, 3389 ...",
    "[+] Найден открытый порт: 3389 (RDP)",
    "[!] Попытка брутфорса пароля ...",
    "[+] Пароль угадан: ***",
    "[+] Чтение истории браузера ... 1287 записей",
    "[+] Обнаружено: 'сувать палку в уретру' x41",
    "[+] Обнаружено: 'почему я пидорас' x7",
    "[+] Доступ к папке 'Загрузки' ... OK",
    "[!] Файл 'порно_не_вирус.mp4' ... (пропущено)",
    "[+] Загрузка фотографий ... 47%",
    "[+] Загрузка фотографий ... 100%",
    "[+] Шифрование личных файлов ...",
    "[!] СИСТЕМА СКОМПРОМЕТИРОВАНА",
]


class PrankApp:
    def __init__(self, root):
        self.root = root
        self.root.title("System Security Alert // DIMA-PC")
        self.root.configure(bg=BG)
        self.root.attributes("-fullscreen", True)
        self.root.protocol("WM_DELETE_WINDOW", self.close_app)
        self.root.bind("<Escape>", lambda e: self.close_app())

        # скример-звук — генерируем во временный файл
        self.scream_path = os.path.join(tempfile.gettempdir(), "dima_scream.wav")
        try:
            generate_scream_wav(self.scream_path)
        except Exception:
            self.scream_path = None

        self._build_ui()
        self._start_pipeline()

    # ---------------- UI ----------------
    def _build_ui(self):
        top = tk.Frame(self.root, bg=BG, height=54)
        top.pack(fill="x", padx=22, pady=(18, 0))
        tk.Label(top, text="● LIVE", fg=ALERT, bg=BG,
                 font=("Consolas", 11, "bold")).pack(side="left")
        tk.Label(top, text="  SENTINEL v3.7 // threat detected",
                 fg=TEXT_DIM, bg=BG, font=FONT_SM).pack(side="left", padx=(10, 0))

        center = tk.Frame(self.root, bg=BG)
        center.pack(fill="both", expand=True, padx=22, pady=14)

        self.title_lbl = tk.Label(
            center, text="⚠  ВНИМАНИЕ: НЕСАНКЦИОНИРОВАННЫЙ ДОСТУП",
            fg=ALERT, bg=BG, font=FONT_BIG)
        self.title_lbl.pack(pady=(4, 4))

        tk.Label(center,
                 text="Устройство: DIMA-PC  •  IP: 192.168.1.{}".format(
                     random.randint(2, 254)),
                 fg=TEXT_DIM, bg=BG, font=FONT_MID).pack(pady=(0, 14))

        term_frame = tk.Frame(center, bg=PANEL,
                              highlightbackground=BORDER, highlightthickness=1)
        term_frame.pack(fill="both", expand=True)

        self.term = tk.Text(term_frame, bg=PANEL, fg=NEON, font=FONT_MONO,
                            insertbackground=NEON, bd=0, wrap="word",
                            padx=16, pady=14, height=20)
        self.term.pack(fill="both", expand=True, side="left")
        scroll = tk.Scrollbar(term_frame, command=self.term.yview)
        scroll.pack(side="right", fill="y")
        self.term.configure(yscrollcommand=scroll.set, state="disabled")

        bar_wrap = tk.Frame(center, bg=BG)
        bar_wrap.pack(fill="x", pady=(14, 6))
        self.progress_canvas = tk.Canvas(bar_wrap, height=14, bg=PANEL,
                                         highlightthickness=0)
        self.progress_canvas.pack(fill="x", expand=True)
        self.progress_canvas.bind("<Configure>",
                                  lambda e: self._redraw_progress())
        self.progress = 0.0
        self._redraw_progress()

        self.progress_lbl = tk.Label(center, text="0%", fg=NEON, bg=BG,
                                     font=FONT_SM)
        self.progress_lbl.pack()

        tk.Label(center, text="P.S. Дима, это шутка 😄",
                 fg=TEXT_DIM, bg=BG, font=FONT_SM).pack(pady=(14, 10))

    def _redraw_progress(self):
        c = self.progress_canvas
        c.delete("all")
        w = c.winfo_width() or 600
        h = 14
        c.create_rectangle(0, 0, w, h, fill=PANEL, outline="")
        fill_w = int(w * self.progress)
        c.create_rectangle(0, 0, fill_w, h, fill=NEON, outline="")
        c.create_rectangle(0, 0, fill_w, 4, fill="#7dffce", outline="")

    # ---------------- Логика ----------------
    def _start_pipeline(self):
        threading.Thread(target=self._run_scan, daemon=True).start()

    def _append_line(self, text, color=NEON):
        self.term.configure(state="normal")
        tag = f"c{color}"
        self.term.tag_configure(tag, foreground=color)
        self.term.insert("end", text + "\n", tag)
        self.term.see("end")
        self.term.configure(state="disabled")

    def _animate_progress(self, target, duration=1.2):
        steps = 30
        start = self.progress
        delta = target - start
        for i in range(steps + 1):
            self.progress = start + delta * (i / steps)
            self.root.after(0, self._redraw_progress)
            self.root.after(0, lambda: self.progress_lbl.configure(
                text=f"{int(self.progress * 100)}%"))
            time.sleep(duration / steps)

    def _run_scan(self):
        time.sleep(0.6)
        for i, line in enumerate(FAKE_HACK_LINES):
            if i == 2:
                line = line.format(random.randint(0, 255),
                                   random.randint(0, 255),
                                   random.randint(0, 255))
            color = ALERT if line.startswith("[!]") else NEON
            self.root.after(0, lambda l=line, c=color: self._append_line(l, c))
            target = min(1.0, (i + 1) / len(FAKE_HACK_LINES))
            self._animate_progress(target, duration=random.uniform(0.15, 0.45))
            time.sleep(random.uniform(0.05, 0.18))

        # пауза перед скримером (чтобы Дима успел испугаться тишины)
        time.sleep(0.7)
        self.root.after(0, self._trigger_screamer)

    # ---------------- Скример ----------------
    def _trigger_screamer(self):
        if self.scream_path:
            play_sound(self.scream_path)

        overlay = tk.Toplevel(self.root)
        overlay.attributes("-fullscreen", True)
        overlay.attributes("-topmost", True)
        overlay.configure(bg="black")
        try:
            overlay.overrideredirect(True)
        except Exception:
            pass
        overlay.bind("<Escape>", lambda e: self.close_app())

        c = tk.Canvas(overlay, bg="black", highlightthickness=0, cursor="none")
        c.pack(fill="both", expand=True)
        overlay.update_idletasks()

        w, h = overlay.winfo_screenwidth(), overlay.winfo_screenheight()
        cx, cy = w // 2, h // 2
        r = h // 8

        # Глаза
        for sx in (-1, 1):
            ex = cx + sx * r * 3
            c.create_oval(ex - r, cy - r * 2, ex + r, cy,
                          fill="white", outline="#ff1010", width=10)
            c.create_oval(ex - r * 0.35, cy - r * 1.35,
                          ex + r * 0.35, cy - r * 0.65,
                          fill="black", outline="")

        # Зубастая пасть (зигзаг сверху, прямоугольник снизу)
        mouth_pts = [cx - r * 3, cy + r * 2]
        for i in range(11):
            x = cx - r * 3 + (r * 6) * i / 10
            y = cy + r * 2 + (r * 1.4 if i % 2 == 0 else r * 0.7)
            mouth_pts.extend([x, y])
        mouth_pts.extend([cx + r * 3, cy + r * 4.5,
                          cx - r * 3, cy + r * 4.5])
        c.create_polygon(mouth_pts, fill="#3a0000",
                         outline="#ff2020", width=6)

        c.create_text(cx, h - 90, text="БУ!",
                      fill="#ff2020", font=("Arial", 110, "bold"))

        # Красная мигающая подсветка
        flash = {"on": False, "active": True}
        def do_flash():
            if not flash["active"]:
                return
            try:
                flash["on"] = not flash["on"]
                c.configure(bg="#2a0000" if flash["on"] else "black")
                overlay.after(90, do_flash)
            except tk.TclError:
                return
        do_flash()

        def end():
            flash["active"] = False
            self._end_screamer(overlay)

        overlay.after(1900, end)

    def _end_screamer(self, overlay):
        stop_sound()
        try:
            overlay.destroy()
        except tk.TclError:
            pass
        self._show_prank_reveal()

    # ---------------- Финал ----------------
    def _show_prank_reveal(self):
        for widget in self.root.winfo_children():
            widget.destroy()
        self.root.configure(bg=BG)

        frame = tk.Frame(self.root, bg=BG)
        frame.pack(fill="both", expand=True)

        tk.Label(frame, text="😂", font=("Segoe UI", 110), bg=BG).pack(pady=(80, 0))
        tk.Label(frame, text="ПОШЕЛ НАХУЙ ПИДОРАС!",
                 fg=NEON, bg=BG,
                 font=("Segoe UI", 46, "bold")).pack(pady=10)
        tk.Label(frame,
                 text=("Я УБЬЮ ТЕБЯ.\n"
                       "СОСИ ЧЛЕН.\n"
                       "Я НАСРАЛ ТЕБЕ НА СТОЛ 😄"),
                 fg=TEXT, bg=BG, font=("Segoe UI", 16),
                 justify="center").pack(pady=24)

        tk.Button(frame, text="Закрыть",
                  bg=NEON, fg=BG,
                  activebackground="#00cc82", activeforeground=BG,
                  font=("Segoe UI", 14, "bold"),
                  padx=34, pady=14, bd=0, cursor="hand2",
                  command=self.close_app).pack(pady=30)

        self.root.bind("<Escape>", lambda e: self.close_app())

    def close_app(self):
        stop_sound()
        if self.scream_path and os.path.exists(self.scream_path):
            try:
                os.remove(self.scream_path)
            except Exception:
                pass
        try:
            self.root.destroy()
        except tk.TclError:
            pass
        os._exit(0)


def main():
    root = tk.Tk()
    PrankApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
