"""從 results/*.dat 重畫頻率響應圖（中文字型需安裝 Noto Sans CJK）"""
import os
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), "results"))
import glob, numpy as np, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib import font_manager as fm
cands=[f.name for f in fm.fontManager.ttflist if "CJK" in f.name and "Sans" in f.name]
plt.rcParams["font.family"]=(cands[:1] or ["Noto Serif CJK TC"])+["DejaVu Sans"]
T={"rc_lpf":("RC 低通濾波器","規格：fc = 1 kHz（900–1100 Hz 通過）"),
   "cs_amp":("共源極放大器","規格：1 kHz 增益 20 dB（17–23 dB 通過）"),
   "opamp":("兩級 CMOS OPA","規格：10 Hz 開迴路增益 ≥ 60 dB")}
C={"qwen25-coder-7b":"#8c8c8c","qwen35-9b":"#e8710a","gemini":"#1a73e8"}
L={"qwen25-coder-7b":"qwen2.5-coder 7B","qwen35-9b":"qwen3.5 9B","gemini":"Gemini 3.5 Flash"}
for tk,(name,spec) in T.items():
    fig,ax=plt.subplots(figsize=(9,5))
    for f in sorted(glob.glob(f"*__{tk}__*.dat")):
        m,_,pt,_=f[:-4].split("__")
        d=np.atleast_2d(np.loadtxt(f))
        ax.semilogx(d[:,0],d[:,-1],color=C[m],ls="-" if pt=="detailed" else "--",lw=2,label=f"{L[m]} / {pt}")
    if tk=="rc_lpf": ax.axvline(1000,color="k",lw=.8,ls=":"); ax.axhline(-3,color="k",lw=.8,ls=":")
    if tk=="cs_amp": ax.axhspan(17,23,color="g",alpha=.08); ax.set_ylim(15,25)
    if tk=="opamp": ax.axhline(60,color="g",lw=1,ls=":",label="60 dB 目標")
    ax.set_title(f"{name}　{spec}",fontsize=13); ax.set_xlabel("頻率 (Hz)"); ax.set_ylabel("增益 (dB)")
    ax.grid(True,which="both",alpha=.3); ax.legend(fontsize=9)
    fig.tight_layout(); fig.savefig(f"plot_{tk}.png",dpi=200); plt.close(fig)
print("done", cands[:1])
