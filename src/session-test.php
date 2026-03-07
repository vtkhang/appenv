<?php
// Start session
session_start();

// Check if form was submitted
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $_SESSION['test_value'] = $_POST['test_value'] ?? null;
    $_SESSION['timestamp'] = time();
    header('Location: session-test.php');
    exit;
}

// Get current session info
$session_id = session_id();
$session_data = $_SESSION;
$php_version = phpversion();
$current_url = $_SERVER['HTTP_HOST'];
?>

<!DOCTYPE html>
<html>
<head>
    <title>Session Test - <?php echo $php_version; ?></title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        .info-box { background: #f0f0f0; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; }
        .cross-links { margin: 20px 0; padding: 15px; background: #e7f3ff; border-radius: 5px; }
        .cross-links a { display: inline-block; margin: 5px 10px 5px 0; padding: 10px 15px; 
                         background: #007bff; color: white; text-decoration: none; border-radius: 3px; }
        .cross-links a:hover { background: #0056b3; }
    </style>
</head>
<body>
    <h1>Session Test (PHP <?php echo $php_version; ?>)</h1>
    
    <div class="info-box">
        <h3>Current Session Info:</h3>
        <p><strong>Session ID:</strong> <?php echo $session_id; ?></p>
        <p><strong>PHP Version:</strong> <?php echo $php_version; ?></p>
        <p><strong>Current URL:</strong> <?php echo $current_url; ?></p>
        <p><strong>Current Time:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
    </div>
    
    <div class="info-box <?php echo !empty($_SESSION['test_value']) ? 'success' : ''; ?>">
        <h3>Session Data:</h3>
        <p><strong>Test Value:</strong> <?php echo $_SESSION['test_value'] ?? '(not set)'; ?></p>
        <p><strong>Timestamp:</strong> <?php echo isset($_SESSION['timestamp']) ? date('Y-m-d H:i:s', $_SESSION['timestamp']) : '(not set)'; ?></p>
        <pre><?php print_r($session_data); ?></pre>
    </div>
    
    <div class="cross-links">
        <h3>Test Cross-Domain Sessions:</h3>
        <p>Click these links to test if session persists across domains:</p>
        <a href="http://php74.localhost/session-test.php">PHP 7.4 (php74.localhost)</a>
        <a href="http://php82.localhost/session-test.php">PHP 8.2 (php82.localhost)</a>
        <a href="http://localhost:8074/session-test.php">PHP 7.4 (port 8074)</a>
        <a href="http://localhost:8082/session-test.php">PHP 8.2 (port 8082)</a>
    </div>
    
    <form method="POST">
        <h3>Set Session Data:</h3>
        <input type="text" name="test_value" placeholder="Enter a value" required>
        <button type="submit">Store in Session</button>
    </form>
    
    <div class="info-box">
        <h3>Session Configuration:</h3>
        <pre>
session.save_handler: <?php echo ini_get('session.save_handler'); ?>
session.save_path: <?php echo ini_get('session.save_path'); ?>
session.cookie_domain: <?php echo ini_get('session.cookie_domain'); ?>
session.cookie_path: <?php echo ini_get('session.cookie_path'); ?>
session.cookie_samesite: <?php echo ini_get('session.cookie_samesite'); ?>
        </pre>
    </div>
</body>
</html>
