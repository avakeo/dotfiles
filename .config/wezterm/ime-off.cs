// 前面ウィンドウ (WezTerm) の IME をオフにして半角英数入力にする。WezTerm でタブ・ペインを切り替えたときに呼ぶ
// ビルド: csc.exe /target:winexe /out:%USERPROFILE%\.local\bin\ime-off.exe ime-off.cs (install.ps1 が行う)
using System;
using System.Runtime.InteropServices;

static class ImeOff
{
    const uint WM_IME_CONTROL = 0x0283;
    const int IMC_SETOPENSTATUS = 0x0006;

    [DllImport("user32.dll")]
    static extern IntPtr GetForegroundWindow();

    [DllImport("imm32.dll")]
    static extern IntPtr ImmGetDefaultIMEWnd(IntPtr hWnd);

    [DllImport("user32.dll")]
    static extern IntPtr SendMessage(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);

    static int Main()
    {
        IntPtr imeWnd = ImmGetDefaultIMEWnd(GetForegroundWindow());
        if (imeWnd == IntPtr.Zero) return 1;
        SendMessage(imeWnd, WM_IME_CONTROL, (IntPtr)IMC_SETOPENSTATUS, IntPtr.Zero);
        return 0;
    }
}
