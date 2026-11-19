<?php
/**
 * Minimal session-based auth. One shared login for Data Entry; Viewer
 * never touches this file and stays fully public.
 */
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

function isLoggedIn() {
    return !empty($_SESSION['user_id']);
}

// Use at the top of any page that must be behind login.
function requireLogin() {
    if (!isLoggedIn()) {
        header('Location: login.php');
        exit;
    }
}

// Use at the top of any api.php action that must be behind login.
function requireLoginApi() {
    if (!isLoggedIn()) {
        http_response_code(401);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['error' => 'Not authenticated']);
        exit;
    }
}
