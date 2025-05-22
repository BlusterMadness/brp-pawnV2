CREATE TABLE IF NOT EXISTS pawn_shop_sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100),
    total_amount INT,
    sold_items JSON,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);