# TcpServer.ps1
$port = 9000
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)
$listener.Start()
Write-Host " TCP Server listening on port $port..."

try {
    while ($true) {
        if ($listener.Pending()) {
            $client = $listener.AcceptTcpClient()
            $stream = $client.GetStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $writer = New-Object System.IO.StreamWriter($stream)
            $writer.AutoFlush = $true

            $remoteEnd = $client.Client.RemoteEndPoint
            Write-Host "📥 Connection from $remoteEnd"

            # Read data sent by client
            $data = $reader.ReadLine()
            Write-Host "Received: $data"

            # Respond to client
            $response = "Server received: $data"
            $writer.WriteLine($response)
            
            $reader.Close()
            $writer.Close()
            $client.Close()
            Write-Host " Response sent and connection closed."
        } else {
            Start-Sleep -Milliseconds 100
        }
    }
} finally {
    $listener.Stop()
}
############################################################
# TcpClient.ps1
$server = "127.0.0.1"
$port = 9000

$client = [System.Net.Sockets.TcpClient]::new($server, $port)
$stream = $client.GetStream()
$reader = New-Object System.IO.StreamReader($stream)
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true

# Send a message to the server
$message = "Hello from client!"
$writer.WriteLine($message)
Write-Host "📤 Sent: $message"

# Receive response from server
$response = $reader.ReadLine()
Write-Host "📥 Received: $response"

$reader.Close()
$writer.Close()
$client.Close()
