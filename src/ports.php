<?php
header('Content-Type: text/html; charset=utf-8');

$portsFile = 'ports.json';
$ports = [];

if (file_exists($portsFile)) {
    $json = file_get_contents($portsFile);
    $ports = json_decode($json, true);
}

// Support for AI agents or programmatic retrieval
if (isset($_GET['format']) && $_GET['format'] === 'json') {
    header('Content-Type: application/json');
    echo json_encode($ports, JSON_PRETTY_PRINT);
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocated Ports Registry</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 40px auto; padding: 0 20px; background-color: #f4f7f6; }
        h1 { border-bottom: 2px solid #2ecc71; padding-bottom: 10px; color: #2c3e50; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; background: white; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #2ecc71; color: white; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 0.05rem; }
        tr:hover { background-color: #f1f1f1; }
        .port { font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace; font-weight: bold; color: #e67e22; }
        .footer { margin-top: 30px; font-size: 0.8rem; color: #7f8c8d; }
        .footer a { color: #3498db; text-decoration: none; }
    </style>
</head>
<body>
    <h1>Allocated Ports Registry</h1>
    <p>The following ports are currently in use by the Docker environment services.</p>
    
    <table>
        <thead>
            <tr>
                <th>Service</th>
                <th>Port (Host)</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($ports as $p): ?>
            <tr>
                <td><strong><?php echo htmlspecialchars($p['service']); ?></strong></td>
                <td><span class="port"><?php echo htmlspecialchars($p['port']); ?></span></td>
                <td><?php echo htmlspecialchars($p['description']); ?></td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>

    <div class="footer">
        Retrieve this as <a href="?format=json">JSON</a>.
    </div>
</body>
</html>
