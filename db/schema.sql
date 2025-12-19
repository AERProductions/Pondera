-- Pondera SQLite Database Schema
-- Version: 1.0
-- Created: 2025-12-16
-- Purpose: Persistent storage for character data, economy, and progression

-- ============================================================================
-- PLAYERS TABLE - Core character metadata
-- ============================================================================
CREATE TABLE IF NOT EXISTS players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ckey TEXT UNIQUE NOT NULL,
    char_name TEXT NOT NULL,
    game_mode TEXT DEFAULT 'story',  -- story, sandbox, pvp, ascension
    current_continent TEXT DEFAULT 'story',
    level INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    last_logout TIMESTAMP,
    online_status BOOLEAN DEFAULT 0,
    ascension_mode BOOLEAN DEFAULT 0,
    ascension_locked BOOLEAN DEFAULT 0,
    death_count INTEGER DEFAULT 0,
    home_point_x INTEGER,
    home_point_y INTEGER,
    home_point_z INTEGER
);

CREATE INDEX idx_players_ckey ON players(ckey);
CREATE INDEX idx_players_online ON players(online_status);
CREATE INDEX idx_players_level ON players(level);

-- ============================================================================
-- CHARACTER SKILLS TABLE - Rank levels and experience tracking
-- ============================================================================
CREATE TABLE IF NOT EXISTS character_skills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    skill_name TEXT NOT NULL,  -- frank, crank, grank, hrank, mrank, smirank, smerank, brank, drank, etc.
    rank_level INTEGER DEFAULT 0,
    current_exp INTEGER DEFAULT 0,
    max_exp_threshold INTEGER DEFAULT 100,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, skill_name)
);

CREATE INDEX idx_skills_player ON character_skills(player_id);
CREATE INDEX idx_skills_rank ON character_skills(rank_level DESC);

-- ============================================================================
-- CURRENCY ACCOUNTS TABLE - Economy tracking (lucre, stone, metal, timber)
-- ============================================================================
CREATE TABLE IF NOT EXISTS currency_accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL UNIQUE,
    lucre INTEGER DEFAULT 0,
    banked_lucre INTEGER DEFAULT 0,
    stone INTEGER DEFAULT 0,
    metal INTEGER DEFAULT 0,
    timber INTEGER DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_currency_lucre ON currency_accounts(lucre DESC);
CREATE INDEX idx_currency_stone ON currency_accounts(stone DESC);

-- ============================================================================
-- RECIPES TABLE - Character recipe discovery
-- ============================================================================
CREATE TABLE IF NOT EXISTS character_recipes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    recipe_name TEXT NOT NULL,
    discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    discovered_via TEXT DEFAULT 'unknown',  -- skill, inspection, npc, etc.
    quality_history TEXT,  -- JSON array of quality scores
    times_crafted INTEGER DEFAULT 0,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, recipe_name)
);

CREATE INDEX idx_recipes_player ON character_recipes(player_id);

-- ============================================================================
-- NPC REPUTATION TABLE - Standing and interactions with NPCs
-- ============================================================================
CREATE TABLE IF NOT EXISTS npc_reputation (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    npc_name TEXT NOT NULL,
    standing INTEGER DEFAULT 0,  -- -1000 to +1000
    tier INTEGER DEFAULT 1,
    taught_topics TEXT,  -- JSON array of knowledge topics
    last_interaction TIMESTAMP,
    interaction_count INTEGER DEFAULT 0,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, npc_name)
);

CREATE INDEX idx_reputation_player ON npc_reputation(player_id);
CREATE INDEX idx_reputation_standing ON npc_reputation(standing DESC);

-- ============================================================================
-- PLAYER DEEDS TABLE - Territory ownership and maintenance
-- ============================================================================
CREATE TABLE IF NOT EXISTS player_deeds (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    deed_id INTEGER NOT NULL UNIQUE,
    tier TEXT DEFAULT 'small',  -- small, medium, large
    maintenance_cost INTEGER,
    maintenance_paid TIMESTAMP,
    maintenance_due TIMESTAMP,
    freeze_status BOOLEAN DEFAULT 0,
    freeze_grace_period TIMESTAMP,
    claimed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_deeds_player ON player_deeds(player_id);
CREATE INDEX idx_deeds_maintenance_due ON player_deeds(maintenance_due);

-- ============================================================================
-- CHARACTER APPEARANCE TABLE - Customization data
-- ============================================================================
CREATE TABLE IF NOT EXISTS character_appearance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL UNIQUE,
    gender TEXT DEFAULT 'M',
    hair_color TEXT,
    skin_tone TEXT,
    eye_color TEXT,
    body_marks TEXT,  -- JSON array
    is_locked BOOLEAN DEFAULT 0,
    last_customized TIMESTAMP,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE
);

-- ============================================================================
-- MARKET BOARD TABLE - Player trading listings
-- ============================================================================
CREATE TABLE IF NOT EXISTS market_board (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    seller_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER DEFAULT 1,
    unit_price INTEGER,
    listing_type TEXT DEFAULT 'sell',  -- sell, buy
    listed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    status TEXT DEFAULT 'active',  -- active, expired, sold, cancelled
    buyer_id INTEGER,
    sold_at TIMESTAMP,
    FOREIGN KEY(seller_id) REFERENCES players(id) ON DELETE CASCADE,
    FOREIGN KEY(buyer_id) REFERENCES players(id)
);

CREATE INDEX idx_market_seller ON market_board(seller_id);
CREATE INDEX idx_market_status ON market_board(status);
CREATE INDEX idx_market_expires ON market_board(expires_at);
CREATE INDEX idx_market_item ON market_board(item_name);

-- ============================================================================
-- MARKET LISTINGS TABLE - Active player-created market board listings
-- ============================================================================
CREATE TABLE IF NOT EXISTS market_listings (
    listing_id INTEGER PRIMARY KEY AUTOINCREMENT,
    seller_id INTEGER NOT NULL,
    seller_name TEXT NOT NULL,
    item_name TEXT NOT NULL,
    item_type TEXT,
    quantity INTEGER DEFAULT 1,
    unit_price INTEGER NOT NULL,
    currency_type TEXT DEFAULT 'lucre',  -- lucre, stone, metal, timber
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT 1,
    buyer_id INTEGER,
    buyer_name TEXT,
    purchased_at TIMESTAMP,
    FOREIGN KEY(seller_id) REFERENCES players(id) ON DELETE CASCADE,
    FOREIGN KEY(buyer_id) REFERENCES players(id)
);

CREATE INDEX idx_listings_seller ON market_listings(seller_id);
CREATE INDEX idx_listings_active ON market_listings(is_active);
CREATE INDEX idx_listings_expires ON market_listings(expires_at);
CREATE INDEX idx_listings_item ON market_listings(item_name);
CREATE INDEX idx_listings_currency ON market_listings(currency_type);

-- ============================================================================
-- NPC MERCHANTS TABLE - NPC merchant state persistence (Phase 3)
-- ============================================================================
CREATE TABLE IF NOT EXISTS npc_merchants (
    merchant_id TEXT PRIMARY KEY,
    merchant_name TEXT NOT NULL,
    merchant_type TEXT,  -- trader, blacksmith, alchemist, etc.
    personality TEXT DEFAULT 'fair',  -- fair, greedy, desperate
    profit_margin REAL DEFAULT 1.0,
    mood INTEGER DEFAULT 0,
    current_wealth INTEGER DEFAULT 0,
    starting_wealth INTEGER DEFAULT 0,
    inventory TEXT,  -- JSON serialized list of items: {item_name: quantity}
    prefers_buying TEXT,  -- JSON serialized list
    prefers_selling TEXT,  -- JSON serialized list
    specialty_items TEXT,  -- JSON serialized list
    last_trade_time TIMESTAMP,
    trading_cooldown INTEGER DEFAULT 30,
    total_trades INTEGER DEFAULT 0,
    total_wealth_traded INTEGER DEFAULT 0,
    reputation INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_merchants_name ON npc_merchants(merchant_name);
CREATE INDEX idx_merchants_type ON npc_merchants(merchant_type);
CREATE INDEX idx_merchants_personality ON npc_merchants(personality);

-- ============================================================================
-- CONTINENT POSITIONS TABLE - Per-continent saved locations
-- ============================================================================
CREATE TABLE IF NOT EXISTS continent_positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    continent TEXT NOT NULL,  -- story, sandbox, pvp, etc.
    x INTEGER,
    y INTEGER,
    z INTEGER,
    dir INTEGER,
    last_saved TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, continent)
);

CREATE INDEX idx_positions_player ON continent_positions(player_id);

-- ============================================================================
-- MARKET HISTORY TABLE - Transaction logs for economy tracking
-- ============================================================================
CREATE TABLE IF NOT EXISTS market_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    seller_id INTEGER NOT NULL,
    buyer_id INTEGER,
    item_name TEXT NOT NULL,
    quantity INTEGER,
    unit_price INTEGER,
    total_price INTEGER,
    transaction_type TEXT,  -- sold, bought, crafted, harvested, etc.
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(seller_id) REFERENCES players(id),
    FOREIGN KEY(buyer_id) REFERENCES players(id)
);

CREATE INDEX idx_history_seller ON market_history(seller_id);
CREATE INDEX idx_history_buyer ON market_history(buyer_id);
CREATE INDEX idx_history_date ON market_history(transaction_date);

-- ============================================================================
-- FACTION ALLEGIANCE TABLE - Faction membership and standing
-- ============================================================================
CREATE TABLE IF NOT EXISTS faction_allegiance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL UNIQUE,
    faction_id TEXT NOT NULL,  -- FACTION_CRIMSON, FACTION_AZURE, etc.
    standing INTEGER DEFAULT 0,  -- -1000 to +1000
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE
);

-- ============================================================================
-- PLAYER STATS TABLE - Combat and survival statistics
-- ============================================================================
CREATE TABLE IF NOT EXISTS player_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL UNIQUE,
    pvp_kills INTEGER DEFAULT 0,
    pve_kills INTEGER DEFAULT 0,
    deaths INTEGER DEFAULT 0,
    playtime_minutes INTEGER DEFAULT 0,
    longest_session_minutes INTEGER DEFAULT 0,
    total_gold_earned INTEGER DEFAULT 0,
    total_gold_spent INTEGER DEFAULT 0,
    total_items_crafted INTEGER DEFAULT 0,
    total_items_harvested INTEGER DEFAULT 0,
    last_stat_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE
);

-- ============================================================================
-- KNOWLEDGE TOPICS TABLE - Discovered lore and information
-- ============================================================================
CREATE TABLE IF NOT EXISTS knowledge_topics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    topic_name TEXT NOT NULL,
    discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    discovered_via TEXT,  -- npc, books, exploration, etc.
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, topic_name)
);

CREATE INDEX idx_knowledge_player ON knowledge_topics(player_id);

-- ============================================================================
-- MIGRATION TRACKING TABLE - Track applied migrations
-- ============================================================================
CREATE TABLE IF NOT EXISTS schema_migrations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    migration_name TEXT UNIQUE NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- VIEWS - Useful queries
-- ============================================================================

-- Top 10 richest players
CREATE VIEW IF NOT EXISTS top_richest_players AS
SELECT 
    p.char_name,
    p.level,
    ca.lucre + ca.stone + ca.metal + ca.timber as total_wealth,
    ca.lucre,
    ca.stone,
    ca.metal,
    ca.timber
FROM players p
JOIN currency_accounts ca ON p.id = ca.player_id
ORDER BY total_wealth DESC
LIMIT 10;

-- Average skill level per player
CREATE VIEW IF NOT EXISTS player_skill_averages AS
SELECT 
    p.char_name,
    AVG(cs.rank_level) as avg_skill_level,
    COUNT(DISTINCT cs.skill_name) as skill_count,
    MAX(cs.rank_level) as max_rank
FROM players p
JOIN character_skills cs ON p.id = cs.player_id
GROUP BY p.id;

-- Active market listings
CREATE VIEW IF NOT EXISTS active_listings AS
SELECT 
    mb.id,
    p.char_name as seller,
    mb.item_name,
    mb.quantity,
    mb.unit_price,
    mb.listing_type,
    mb.listed_at,
    mb.expires_at
FROM market_board mb
JOIN players p ON mb.seller_id = p.id
WHERE mb.status = 'active' AND mb.expires_at > CURRENT_TIMESTAMP;

-- ============================================================================
-- MARKET PRICES TABLE - Dynamic commodity pricing system
-- ============================================================================
CREATE TABLE IF NOT EXISTS market_prices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_name TEXT UNIQUE NOT NULL,
    base_price REAL DEFAULT 1.0,
    current_price REAL DEFAULT 1.0,
    price_elasticity REAL DEFAULT 1.0,
    price_volatility REAL DEFAULT 0.1,
    supply_count INTEGER DEFAULT 0,
    tech_tier INTEGER DEFAULT 1,
    min_price REAL DEFAULT 0.5,
    max_price REAL DEFAULT 10.0,
    tradable BOOLEAN DEFAULT 1,
    sellable BOOLEAN DEFAULT 1,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by TEXT DEFAULT 'system'  -- system, admin, market_dynamics
);

CREATE INDEX idx_market_commodity ON market_prices(commodity_name);
CREATE INDEX idx_market_price ON market_prices(current_price DESC);
CREATE INDEX idx_market_updated ON market_prices(updated_at DESC);

-- Phase 6: Market Price History Table - Track price changes over time
CREATE TABLE IF NOT EXISTS price_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_name TEXT NOT NULL,
    historical_price REAL NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    market_conditions TEXT,
    supply_level INTEGER,
    demand_level INTEGER,
    FOREIGN KEY (commodity_name) REFERENCES market_prices(commodity_name)
);

CREATE INDEX idx_price_history_commodity ON price_history(commodity_name);
CREATE INDEX idx_price_history_recorded ON price_history(recorded_at DESC);
CREATE INDEX idx_price_history_lookup ON price_history(commodity_name, recorded_at DESC);

-- ============================================================================
-- HUD STATE TABLE - Player HUD preferences and toolbelt layout (Phase 4)
-- ============================================================================
CREATE TABLE IF NOT EXISTS hud_state (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL UNIQUE,
    toolbelt_layout TEXT,  -- Comma-separated tool names in slots (slot1:tool1|slot2:tool2...)
    current_slot INTEGER DEFAULT 1,  -- Current active hotbar slot
    inventory_visible BOOLEAN DEFAULT 0,  -- Was inventory panel visible?
    stats_visible BOOLEAN DEFAULT 1,  -- Stats panel visibility
    currency_visible BOOLEAN DEFAULT 1,  -- Currency display visibility
    panel_positions TEXT,  -- JSON: {panel_name: {x, y}, ...} Phase 4 addition
    panel_states TEXT,  -- JSON: {panel_name: {width, height, collapsed}, ...} Phase 4 addition
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_hud_player ON hud_state(player_id);

-- ============================================================================
-- DEEDS TABLE - Territory/zone ownership and maintenance (Phase 5)
-- ============================================================================
CREATE TABLE IF NOT EXISTS deeds (
    deed_id INTEGER PRIMARY KEY,
    owner_id INTEGER NOT NULL,
    zone_name TEXT NOT NULL,
    zone_tier TEXT DEFAULT 'small',  -- small, medium, large
    center_x INTEGER,
    center_y INTEGER,
    center_z INTEGER,
    size_x INTEGER,
    size_y INTEGER,
    allowed_players TEXT,  -- JSON: ["ckey1", "ckey2", ...] list of authorized players
    maintenance_cost INTEGER DEFAULT 100,
    maintenance_due TIMESTAMP,
    founded_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grace_period_end TIMESTAMP,  -- Non-payment grace period expiration
    payment_frozen BOOLEAN DEFAULT 0,  -- Is payment freeze active?
    frozen_start TIMESTAMP,  -- When freeze was activated
    freeze_duration INTEGER DEFAULT 0,  -- How many ticks to freeze (in deciseconds)
    freezes_used_this_month INTEGER DEFAULT 0,  -- Current month freeze count (max 2)
    last_freeze_month INTEGER DEFAULT 0,  -- Timestamp of when freezes were last reset
    cooldown_end TIMESTAMP,  -- Early unfreeze cooldown expiration
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(owner_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_deeds_owner ON deeds(owner_id);
CREATE INDEX idx_deeds_maintenance_due ON deeds(maintenance_due);
CREATE INDEX idx_deeds_frozen ON deeds(payment_frozen);
CREATE INDEX idx_deeds_zone_name ON deeds(zone_name);

-- Phase 7: Market Analytics Metrics Table - Computed analytics for player display
CREATE TABLE IF NOT EXISTS market_analytics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_name TEXT UNIQUE NOT NULL,
    avg_price_7d REAL DEFAULT 0.0,          -- 7-day average price
    avg_price_30d REAL DEFAULT 0.0,         -- 30-day average price
    price_volatility REAL DEFAULT 0.0,      -- Price change rate (%)
    min_price_7d REAL DEFAULT 0.0,          -- Lowest price in 7 days
    max_price_7d REAL DEFAULT 0.0,          -- Highest price in 7 days
    supply_level INTEGER DEFAULT 0,         -- Current market supply
    demand_level INTEGER DEFAULT 0,         -- Current market demand
    popularity_score INTEGER DEFAULT 0,     -- Transaction frequency (0-100)
    scarcity_index REAL DEFAULT 0.5,        -- Supply/demand ratio (0.0-1.0, 0=scarce, 1=abundant)
    price_trend TEXT DEFAULT 'stable',      -- 'rising', 'falling', or 'stable'
    trend_strength INTEGER DEFAULT 0,       -- Strength of trend (0-100)
    transaction_count INTEGER DEFAULT 0,    -- Total transactions this period
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    calculated_by TEXT DEFAULT 'system',    -- Who calculated (system, admin, etc)
    FOREIGN KEY (commodity_name) REFERENCES market_prices(commodity_name)
);

CREATE INDEX idx_analytics_commodity ON market_analytics(commodity_name);
CREATE INDEX idx_analytics_popularity ON market_analytics(popularity_score DESC);
CREATE INDEX idx_analytics_scarcity ON market_analytics(scarcity_index);
CREATE INDEX idx_analytics_trend ON market_analytics(price_trend);
CREATE INDEX idx_analytics_updated ON market_analytics(updated_at DESC);

-- ============================================================================
-- MARKET TRANSACTIONS TABLE - Advanced transaction logging (Phase 8)
-- ============================================================================
CREATE TABLE IF NOT EXISTS market_transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    seller_id INTEGER NOT NULL,
    buyer_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price REAL NOT NULL,
    total_price REAL NOT NULL,
    currency_type TEXT DEFAULT 'lucre',
    transaction_type TEXT DEFAULT 'direct',  -- direct, auction, settlement, contract
    settlement_status TEXT DEFAULT 'completed',  -- pending, completed, disputed, cancelled, refunded
    seller_confirmed BOOLEAN DEFAULT 0,
    buyer_confirmed BOOLEAN DEFAULT 0,
    dispute_filed BOOLEAN DEFAULT 0,
    dispute_reason TEXT,
    dispute_resolution TEXT,  -- settlement_rejected, settlement_accepted, refunded, compensation_awarded
    dispute_filed_at TIMESTAMP,
    dispute_resolved_at TIMESTAMP,
    escrow_amount REAL DEFAULT 0.0,
    escrow_held_by TEXT,  -- admin, system, player_mediator
    initiated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    settled_at TIMESTAMP,
    expires_at TIMESTAMP,
    trade_verification_code TEXT,  -- Random code for verification
    verification_attempts INTEGER DEFAULT 0,
    market_fee_collected REAL DEFAULT 0.0,
    notes TEXT,
    FOREIGN KEY(seller_id) REFERENCES players(id) ON DELETE CASCADE,
    FOREIGN KEY(buyer_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_transactions_seller ON market_transactions(seller_id);
CREATE INDEX idx_transactions_buyer ON market_transactions(buyer_id);
CREATE INDEX idx_transactions_status ON market_transactions(settlement_status);
CREATE INDEX idx_transactions_date ON market_transactions(initiated_at DESC);
CREATE INDEX idx_transactions_dispute ON market_transactions(dispute_filed);
CREATE INDEX idx_transactions_item ON market_transactions(item_name);
CREATE INDEX idx_transactions_verification ON market_transactions(trade_verification_code);

-- ============================================================================
-- PLAYER TRADING ANALYTICS TABLE - Per-player trading statistics (Phase 8)
-- ============================================================================
CREATE TABLE IF NOT EXISTS player_trading_analytics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL UNIQUE,
    total_trades_completed INTEGER DEFAULT 0,
    total_trades_volume REAL DEFAULT 0.0,
    total_trading_profit REAL DEFAULT 0.0,
    average_trade_size REAL DEFAULT 0.0,
    disputes_initiated INTEGER DEFAULT 0,
    disputes_won INTEGER DEFAULT 0,
    disputes_lost INTEGER DEFAULT 0,
    seller_reputation_score REAL DEFAULT 50.0,  -- 0-100, 50 is neutral
    buyer_reputation_score REAL DEFAULT 50.0,
    avg_settlement_time_seconds INTEGER DEFAULT 0,
    last_trade_date TIMESTAMP,
    favorite_items TEXT,  -- JSON: {item_name: trade_count}
    trading_tier TEXT DEFAULT 'novice',  -- novice, intermediate, expert, master
    market_insights TEXT,  -- JSON: {commodity_name: {preferred_price, frequency}}
    trust_rating REAL DEFAULT 0.0,  -- Based on dispute ratio and settlement history
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_trading_player ON player_trading_analytics(player_id);
CREATE INDEX idx_trading_reputation ON player_trading_analytics(seller_reputation_score DESC);
CREATE INDEX idx_trading_volume ON player_trading_analytics(total_trading_profit DESC);
CREATE INDEX idx_trading_tier ON player_trading_analytics(trading_tier);

-- ============================================================================
-- MARKET SETTLEMENT HISTORY TABLE - Track all settlement transactions (Phase 8)
-- ============================================================================
CREATE TABLE IF NOT EXISTS market_settlement_history (
    settlement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_id INTEGER NOT NULL,
    settlement_type TEXT,  -- immediate, escrow, delayed, negotiated
    settler_id INTEGER,  -- Who performed settlement (admin, system, mediator)
    settlement_amount REAL NOT NULL,
    settlement_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    settlement_notes TEXT,
    buyer_satisfaction INTEGER,  -- 1-5 rating
    seller_satisfaction INTEGER,  -- 1-5 rating
    FOREIGN KEY(transaction_id) REFERENCES market_transactions(transaction_id),
    FOREIGN KEY(settler_id) REFERENCES players(id)
);

CREATE INDEX idx_settlement_transaction ON market_settlement_history(transaction_id);
CREATE INDEX idx_settlement_timestamp ON market_settlement_history(settlement_timestamp DESC);

-- ============================================================================
-- MARKET DISPUTES TABLE - Centralized dispute tracking and resolution (Phase 8)
-- ============================================================================
CREATE TABLE IF NOT EXISTS market_disputes (
    dispute_id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_id INTEGER NOT NULL UNIQUE,
    initiator_id INTEGER NOT NULL,
    defendant_id INTEGER NOT NULL,
    dispute_type TEXT,  -- non_delivery, wrong_item, wrong_quantity, quality_issue, other
    description TEXT NOT NULL,
    evidence TEXT,  -- JSON array of evidence file paths or descriptions
    status TEXT DEFAULT 'open',  -- open, in_review, awaiting_response, resolved, closed
    priority TEXT DEFAULT 'normal',  -- low, normal, high, critical
    assigned_to INTEGER,  -- Admin/moderator handling dispute
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    response_deadline TIMESTAMP,
    resolved_at TIMESTAMP,
    resolution_text TEXT,
    compensation_amount REAL DEFAULT 0.0,
    refund_issued BOOLEAN DEFAULT 0,
    FOREIGN KEY(transaction_id) REFERENCES market_transactions(transaction_id),
    FOREIGN KEY(initiator_id) REFERENCES players(id),
    FOREIGN KEY(defendant_id) REFERENCES players(id),
    FOREIGN KEY(assigned_to) REFERENCES players(id)
);

CREATE INDEX idx_disputes_transaction ON market_disputes(transaction_id);
CREATE INDEX idx_disputes_initiator ON market_disputes(initiator_id);
CREATE INDEX idx_disputes_status ON market_disputes(status);
CREATE INDEX idx_disputes_priority ON market_disputes(priority);
CREATE INDEX idx_disputes_created ON market_disputes(created_at DESC);

-- ============================================================================
-- CRAFTING & RECIPE PERSISTENCE TABLES (Phase 9)
-- ============================================================================
CREATE TABLE IF NOT EXISTS crafting_recipes (
    recipe_id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_name TEXT UNIQUE NOT NULL,
    recipe_type TEXT,  -- cooking, smithing, crafting, alchemy, building, etc.
    skill_requirement TEXT,  -- frank, smirank, crank, etc.
    skill_level_required INTEGER DEFAULT 1,
    output_item TEXT NOT NULL,
    output_quantity INTEGER DEFAULT 1,
    quality_modifier REAL DEFAULT 1.0,
    base_quality INTEGER DEFAULT 75,
    ingredients TEXT NOT NULL,  -- JSON: {item_name: quantity, ...}
    tool_required TEXT,  -- Optional tool name
    difficulty_tier INTEGER DEFAULT 1,
    exp_reward INTEGER DEFAULT 10,
    profit_potential REAL DEFAULT 1.0,
    enabled BOOLEAN DEFAULT 1,
    discovery_method TEXT DEFAULT 'skill',  -- skill, npc, inspection, exploration
    base_duration_seconds INTEGER DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_recipes_name ON crafting_recipes(recipe_name);
CREATE INDEX idx_recipes_type ON crafting_recipes(recipe_type);
CREATE INDEX idx_recipes_skill ON crafting_recipes(skill_requirement, skill_level_required);
CREATE INDEX idx_recipes_difficulty ON crafting_recipes(difficulty_tier);

-- ============================================================================
-- PLAYER RECIPE DISCOVERY TRACKER (Phase 9)
-- ============================================================================
CREATE TABLE IF NOT EXISTS player_recipe_discovery (
    discovery_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    recipe_id INTEGER NOT NULL,
    recipe_name TEXT NOT NULL,
    discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    discovery_method TEXT,  -- skill_unlock, npc_teaching, inspection, exploration, experimentation
    discoverer_npc TEXT,  -- NPC who taught, if applicable
    discovery_location TEXT,  -- Location discovered (for exploration)
    skill_level_at_discovery INTEGER,
    times_crafted INTEGER DEFAULT 0,
    quality_history TEXT,  -- JSON: [75, 82, 80, 85, ...] recent quality scores
    favorite_ingredient_substitutions TEXT,  -- JSON: {ingredient: substitute, ...}
    notes TEXT,  -- Custom player notes
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE,
    FOREIGN KEY(recipe_id) REFERENCES crafting_recipes(recipe_id),
    UNIQUE(player_id, recipe_id)
);

CREATE INDEX idx_discovery_player ON player_recipe_discovery(player_id);
CREATE INDEX idx_discovery_method ON player_recipe_discovery(discovery_method);
CREATE INDEX idx_discovery_date ON player_recipe_discovery(discovered_at DESC);

-- ============================================================================
-- CRAFTING HISTORY TABLE - Track all crafting activities (Phase 9)
-- ============================================================================
CREATE TABLE IF NOT EXISTS crafting_history (
    craft_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    recipe_name TEXT NOT NULL,
    recipe_type TEXT,
    ingredient_quality_average REAL DEFAULT 75.0,
    crafted_item_quality INTEGER,
    exp_gained INTEGER,
    materials_wasted INTEGER DEFAULT 0,
    duration_seconds INTEGER,
    success BOOLEAN DEFAULT 1,
    failure_reason TEXT,  -- insufficient_materials, insufficient_skill, etc.
    crafted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    location_x INTEGER,
    location_y INTEGER,
    location_z INTEGER,
    tool_used TEXT,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_crafting_player ON crafting_history(player_id);
CREATE INDEX idx_crafting_recipe ON crafting_history(recipe_name);
CREATE INDEX idx_crafting_date ON crafting_history(crafted_at DESC);
CREATE INDEX idx_crafting_quality ON crafting_history(crafted_item_quality DESC);

-- ============================================================================
-- PLAYER CRAFTING SPECIALIZATION (Phase 9)
-- ============================================================================
CREATE TABLE IF NOT EXISTS player_crafting_specialization (
    spec_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL UNIQUE,
    preferred_recipe_types TEXT,  -- JSON: ["cooking", "smithing", ...] priority order
    total_crafts_completed INTEGER DEFAULT 0,
    total_exp_gained INTEGER DEFAULT 0,
    average_quality REAL DEFAULT 75.0,
    specialization_tier TEXT DEFAULT 'novice',  -- novice, apprentice, journeyman, master, expert
    favorite_recipes TEXT,  -- JSON: {recipe_name: craft_count, ...}
    ingredient_preferences TEXT,  -- JSON: {ingredient: preference_score, ...}
    crafting_speed_bonus REAL DEFAULT 1.0,  -- 1.0 = normal, >1.0 = faster
    quality_consistency REAL DEFAULT 0.75,  -- Higher = more consistent quality
    last_recipe_crafted TEXT,
    last_craft_date TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_specialization_player ON player_crafting_specialization(player_id);
CREATE INDEX idx_specialization_tier ON player_crafting_specialization(specialization_tier);

-- ============================================================================
-- RECIPE INGREDIENT MASTER LIST (Phase 9)
-- ============================================================================
CREATE TABLE IF NOT EXISTS recipe_ingredients (
    ingredient_id INTEGER PRIMARY KEY AUTOINCREMENT,
    ingredient_name TEXT UNIQUE NOT NULL,
    ingredient_type TEXT,  -- food, material, component, herb, ore, etc.
    base_quality_contribution REAL DEFAULT 1.0,
    rarity_tier INTEGER DEFAULT 1,
    seasonal_availability TEXT,  -- JSON: ["spring", "summer", ...] or null for year-round
    biome_sources TEXT,  -- JSON: ["temperate", "arctic", ...] where obtainable
    shelf_life_days INTEGER,  -- Days before spoiling (null = non-perishable)
    nutrition_value INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ingredients_name ON recipe_ingredients(ingredient_name);
CREATE INDEX idx_ingredients_type ON recipe_ingredients(ingredient_type);
CREATE INDEX idx_ingredients_rarity ON recipe_ingredients(rarity_tier);

-- ============================================================================
-- CRAFTING MASTERY ACHIEVEMENTS (Phase 9)
-- ============================================================================
CREATE TABLE IF NOT EXISTS crafting_achievements (
    achievement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    achievement_type TEXT,  -- first_craft, milestone_100_crafts, perfect_quality_100, specialty_master, etc.
    recipe_type TEXT,  -- Relevant recipe type
    achievement_name TEXT NOT NULL,
    achievement_description TEXT,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reward_exp INTEGER DEFAULT 0,
    reward_currency REAL DEFAULT 0.0,
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, achievement_type, recipe_type)
);

CREATE INDEX idx_achievements_player ON crafting_achievements(player_id);
CREATE INDEX idx_achievements_type ON crafting_achievements(achievement_type);
CREATE INDEX idx_achievements_date ON crafting_achievements(earned_at DESC);

-- ============================================================================
-- MARKET PREDICTION & FORECASTING TABLES (Phase 10)
-- ============================================================================
CREATE TABLE IF NOT EXISTS price_forecast_models (
    model_id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_name TEXT NOT NULL,
    model_type TEXT,  -- linear_regression, moving_average, seasonal_decomposition, arima, ensemble
    accuracy_score REAL DEFAULT 0.0,  -- Model accuracy (0-1)
    prediction_horizon_days INTEGER DEFAULT 7,
    parameters TEXT,  -- JSON: model-specific parameters
    training_data_points INTEGER,  -- Number of data points used to train
    model_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    model_last_retrained TIMESTAMP,
    model_performance_metrics TEXT,  -- JSON: {mse, mae, rmse, r_squared}
    enabled BOOLEAN DEFAULT 1,
    UNIQUE(commodity_name, model_type)
);

CREATE INDEX idx_models_commodity ON price_forecast_models(commodity_name);
CREATE INDEX idx_models_accuracy ON price_forecast_models(accuracy_score DESC);

-- ============================================================================
-- PRICE PREDICTIONS TABLE - Individual price forecasts (Phase 10)
-- ============================================================================
CREATE TABLE IF NOT EXISTS price_predictions (
    prediction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_name TEXT NOT NULL,
    model_id INTEGER,
    predicted_price REAL NOT NULL,
    confidence_interval_low REAL,
    confidence_interval_high REAL,
    confidence_level REAL DEFAULT 0.95,  -- 95% confidence
    prediction_date DATE,  -- Date of prediction
    prediction_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actual_price REAL,  -- Filled in after date passes
    actual_recorded_at TIMESTAMP,  -- When actual price was recorded
    prediction_accuracy REAL,  -- |actual - predicted| / predicted * 100
    trend_direction TEXT,  -- 'up', 'down', 'stable'
    FOREIGN KEY(commodity_name) REFERENCES market_prices(commodity_name),
    FOREIGN KEY(model_id) REFERENCES price_forecast_models(model_id)
);

CREATE INDEX idx_predictions_commodity ON price_predictions(commodity_name);
CREATE INDEX idx_predictions_date ON price_predictions(prediction_date);
CREATE INDEX idx_predictions_created ON price_predictions(prediction_created_at DESC);

-- ============================================================================
-- SUPPLY CHAIN DISRUPTION ALERTS (Phase 10)
-- ============================================================================
CREATE TABLE IF NOT EXISTS supply_disruption_alerts (
    alert_id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_name TEXT NOT NULL,
    disruption_type TEXT,  -- supply_shortage, demand_spike, production_halt, resource_depletion, market_crash, artificial_inflation
    severity TEXT DEFAULT 'medium',  -- low, medium, high, critical
    alert_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_duration_hours INTEGER,
    impact_description TEXT,
    estimated_price_change REAL,  -- Predicted price change percentage
    recommended_action TEXT,  -- Buy, sell, hold, accumulate, sell_caution
    auto_recovery BOOLEAN DEFAULT 0,
    recovery_predicted_at TIMESTAMP,
    alert_resolved BOOLEAN DEFAULT 0,
    resolved_at TIMESTAMP,
    actual_impact REAL,  -- Actual price change percentage
    FOREIGN KEY(commodity_name) REFERENCES market_prices(commodity_name)
);

CREATE INDEX idx_alerts_commodity ON supply_disruption_alerts(commodity_name);
CREATE INDEX idx_alerts_severity ON supply_disruption_alerts(severity);
CREATE INDEX idx_alerts_active ON supply_disruption_alerts(alert_resolved);
CREATE INDEX idx_alerts_timestamp ON supply_disruption_alerts(alert_timestamp DESC);

-- ============================================================================
-- SEASONAL DEMAND PATTERNS TABLE (Phase 10)
-- ============================================================================
CREATE TABLE IF NOT EXISTS seasonal_demand_patterns (
    pattern_id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_name TEXT NOT NULL,
    season TEXT NOT NULL,  -- spring, summer, autumn, winter
    average_demand INTEGER,
    demand_variance REAL,  -- Standard deviation
    average_price REAL,
    price_variance REAL,
    peak_days TEXT,  -- JSON array of high-demand days
    low_days TEXT,  -- JSON array of low-demand days
    trend_description TEXT,
    historical_accuracy REAL DEFAULT 0.0,  -- How accurate predictions are for this pattern
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(commodity_name, season)
);

CREATE INDEX idx_patterns_commodity ON seasonal_demand_patterns(commodity_name);
CREATE INDEX idx_patterns_season ON seasonal_demand_patterns(season);

-- ============================================================================
-- COMMODITY CORRELATION ANALYSIS TABLE (Phase 10)
-- ============================================================================
CREATE TABLE IF NOT EXISTS commodity_correlations (
    correlation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_a TEXT NOT NULL,
    commodity_b TEXT NOT NULL,
    correlation_coefficient REAL,  -- -1.0 to 1.0
    correlation_type TEXT,  -- positive_strong, positive_weak, negative_strong, negative_weak, uncorrelated
    causation_type TEXT,  -- substitutes, complements, competing_demand, none
    data_period_days INTEGER DEFAULT 30,
    observations INTEGER,  -- Number of data points in analysis
    analysis_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(commodity_a, commodity_b)
);

CREATE INDEX idx_correlation_a ON commodity_correlations(commodity_a);
CREATE INDEX idx_correlation_b ON commodity_correlations(commodity_b);
CREATE INDEX idx_correlation_strength ON commodity_correlations(correlation_coefficient);

-- ============================================================================
-- PLAYER MARKET INSIGHTS & RECOMMENDATIONS (Phase 10)
-- ============================================================================
CREATE TABLE IF NOT EXISTS player_market_insights (
    insight_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    recommendation_type TEXT,  -- buy_opportunity, sell_peak, accumulate, diversify, avoid_volatile
    commodity_name TEXT,
    confidence_level REAL DEFAULT 0.75,  -- 0-1 confidence
    recommended_quantity INTEGER,
    expected_profit_percent REAL,
    target_price REAL,
    stop_loss_price REAL,
    insight_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    insight_expires_at TIMESTAMP,
    player_acted_on BOOLEAN DEFAULT 0,
    actual_result REAL,  -- Actual profit/loss percentage
    FOREIGN KEY(player_id) REFERENCES players(id) ON DELETE CASCADE,
    FOREIGN KEY(commodity_name) REFERENCES market_prices(commodity_name)
);

CREATE INDEX idx_insights_player ON player_market_insights(player_id);
CREATE INDEX idx_insights_commodity ON player_market_insights(commodity_name);
CREATE INDEX idx_insights_type ON player_market_insights(recommendation_type);
CREATE INDEX idx_insights_created ON player_market_insights(insight_created_at DESC);

-- ============================================================================
-- MARKET TREND ANALYSIS SNAPSHOTS (Phase 10)
-- ============================================================================
CREATE TABLE IF NOT EXISTS market_trend_snapshots (
    snapshot_id INTEGER PRIMARY KEY AUTOINCREMENT,
    snapshot_date DATE UNIQUE,
    total_commodities INTEGER,
    average_price REAL,
    average_volatility REAL,
    bullish_count INTEGER,  -- Rising commodities
    bearish_count INTEGER,  -- Falling commodities
    neutral_count INTEGER,  -- Stable commodities
    market_sentiment TEXT,  -- 'very_bullish', 'bullish', 'neutral', 'bearish', 'very_bearish'
    volatility_index REAL DEFAULT 50.0,  -- VIX-like volatility index (0-100)
    trading_volume_total REAL,
    major_movers TEXT,  -- JSON: top 5 gainers/losers
    risk_level TEXT DEFAULT 'medium',  -- low, medium, high
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_snapshots_date ON market_trend_snapshots(snapshot_date DESC);
CREATE INDEX idx_snapshots_sentiment ON market_trend_snapshots(market_sentiment);

-- ============================================================================
-- GLOBAL RESOURCE STATE TABLES (Phase 11A)
-- ============================================================================
CREATE TABLE IF NOT EXISTS global_resources (
    resource_id INTEGER PRIMARY KEY AUTOINCREMENT,
    resource_type TEXT UNIQUE NOT NULL,  -- 'stone', 'metal', 'timber', 'supply_box'
    current_amount BIGINT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_generated_all_time BIGINT DEFAULT 0,
    total_consumed_all_time BIGINT DEFAULT 0,
    avg_price_current REAL DEFAULT 1.0,
    scarcity_level TEXT DEFAULT 'normal',  -- abundant, normal, scarce, critical
    inflation_index REAL DEFAULT 1.0  -- 1.0 = baseline, >1.0 = inflation
);

CREATE INDEX idx_resources_type ON global_resources(resource_type);

-- ============================================================================
-- RESOURCE TRANSACTION HISTORY (Phase 11A)
-- ============================================================================
CREATE TABLE IF NOT EXISTS resource_transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    resource_type TEXT NOT NULL,
    transaction_type TEXT,  -- harvested, crafted, traded, consumed, gifted, destroyed, admin_adjustment
    amount_change BIGINT NOT NULL,
    resulting_amount BIGINT,
    related_player_id INTEGER,
    related_entity TEXT,  -- item_name, recipe_name, deed_name, etc.
    continent TEXT,  -- which continent event happened on (story/sandbox/pvp)
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY(resource_type) REFERENCES global_resources(resource_type)
);

CREATE INDEX idx_transactions_resource ON resource_transactions(resource_type);
CREATE INDEX idx_transactions_type ON resource_transactions(transaction_type);
CREATE INDEX idx_transactions_player ON resource_transactions(related_player_id);
CREATE INDEX idx_transactions_date ON resource_transactions(recorded_at DESC);
CREATE INDEX idx_transactions_continent ON resource_transactions(continent);

-- ============================================================================
-- NPC STATE & PERSISTENCE TABLES (Phase 11B)
-- ============================================================================
CREATE TABLE IF NOT EXISTS npc_persistent_state (
    npc_id INTEGER PRIMARY KEY AUTOINCREMENT,
    npc_name TEXT UNIQUE NOT NULL,
    npc_type TEXT,  -- merchant, guard, quest_giver, companion, wanderer, etc.
    current_continent TEXT,  -- story, sandbox, pvp
    current_x INTEGER,
    current_y INTEGER,
    current_z INTEGER,
    current_hp INTEGER DEFAULT 100,
    current_stamina INTEGER DEFAULT 100,
    emotional_state TEXT DEFAULT 'neutral',  -- happy, angry, neutral, afraid, sad, excited
    emotional_intensity INTEGER DEFAULT 50,  -- 0-100
    inventory_json TEXT,  -- JSON: {item_name: quantity, ...}
    personality TEXT DEFAULT 'balanced',  -- greedy, fair, honest, deceptive, aggressive, peaceful
    last_player_interaction_id INTEGER,
    last_interaction_time TIMESTAMP,
    total_interactions INTEGER DEFAULT 0,
    is_alive BOOLEAN DEFAULT 1,
    last_location_change TIMESTAMP,
    behavior_flags TEXT,  -- JSON: {flag_name: value}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(last_player_interaction_id) REFERENCES players(id)
);

CREATE INDEX idx_npc_name ON npc_persistent_state(npc_name);
CREATE INDEX idx_npc_type ON npc_persistent_state(npc_type);
CREATE INDEX idx_npc_continent ON npc_persistent_state(current_continent);
CREATE INDEX idx_npc_location ON npc_persistent_state(current_x, current_y, current_z);
CREATE INDEX idx_npc_alive ON npc_persistent_state(is_alive);

-- ============================================================================
-- NPC ROUTINE SCHEDULES (Phase 11B)
-- ============================================================================
CREATE TABLE IF NOT EXISTS npc_schedules (
    schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    npc_id INTEGER NOT NULL,
    day_of_week TEXT,  -- 'Monday', 'Tuesday', ... or 'daily', 'weekly', 'seasonal'
    hour_start INTEGER,  -- 0-23
    hour_end INTEGER,    -- 0-23
    location_x INTEGER,
    location_y INTEGER,
    location_z INTEGER,
    activity_type TEXT,  -- 'patrolling', 'resting', 'trading', 'crafting', 'socializing', 'hunting', 'gathering'
    activity_priority INTEGER DEFAULT 50,  -- 0-100, affects override likelihood
    travel_path_waypoints TEXT,  -- JSON array of {x,y,z} waypoints
    dialogue_topic TEXT,  -- What NPC discusses during this time
    FOREIGN KEY(npc_id) REFERENCES npc_persistent_state(npc_id) ON DELETE CASCADE,
    UNIQUE(npc_id, day_of_week, hour_start)
);

CREATE INDEX idx_schedule_npc ON npc_schedules(npc_id);
CREATE INDEX idx_schedule_day ON npc_schedules(day_of_week);
CREATE INDEX idx_schedule_time ON npc_schedules(hour_start, hour_end);

-- ============================================================================
-- NPC RELATIONSHIPS & INTERACTIONS (Phase 11B)
-- ============================================================================
CREATE TABLE IF NOT EXISTS npc_relationships (
    relationship_id INTEGER PRIMARY KEY AUTOINCREMENT,
    npc_id INTEGER NOT NULL,
    other_entity_id TEXT,  -- player_id or other_npc_id
    other_entity_type TEXT,  -- 'player' or 'npc'
    relationship_type TEXT,  -- 'ally', 'enemy', 'neutral', 'friend', 'rival', 'superior', 'subordinate'
    strength INTEGER DEFAULT 0,  -- -1000 to +1000 (negative = hostile, positive = friendly)
    history_interactions INTEGER DEFAULT 0,
    history_trades INTEGER DEFAULT 0,
    history_gifts_given INTEGER DEFAULT 0,
    history_insults_received INTEGER DEFAULT 0,
    last_interaction TIMESTAMP,
    memory_notes TEXT,  -- What NPC remembers about this entity
    FOREIGN KEY(npc_id) REFERENCES npc_persistent_state(npc_id) ON DELETE CASCADE,
    UNIQUE(npc_id, other_entity_id)
);

CREATE INDEX idx_relationships_npc ON npc_relationships(npc_id);
CREATE INDEX idx_relationships_other ON npc_relationships(other_entity_id);
CREATE INDEX idx_relationships_strength ON npc_relationships(strength DESC);

-- ============================================================================
-- WORLD CALENDAR & SEASONAL STATE (Phase 11C)
-- ============================================================================
CREATE TABLE IF NOT EXISTS world_calendar (
    day_id INTEGER PRIMARY KEY AUTOINCREMENT,
    day_number INTEGER UNIQUE NOT NULL,
    season TEXT,  -- 'spring', 'summer', 'autumn', 'winter'
    month INTEGER,  -- 1-12
    year INTEGER,
    day_of_week TEXT,  -- 'Monday', 'Tuesday', ...
    time_of_day_minutes INTEGER DEFAULT 0,  -- 0-1440 (0 = midnight, 720 = noon)
    weather_type TEXT DEFAULT 'clear',  -- clear, cloudy, rainy, snowy, stormy, foggy
    weather_intensity INTEGER DEFAULT 0,  -- 0-100
    temperature_modifier REAL DEFAULT 0.0,  -- -50 to +50, affects hunger/thirst rate
    daylight_hours INTEGER DEFAULT 12,  -- Season-dependent
    is_festival_day BOOLEAN DEFAULT 0,
    festival_name TEXT,
    special_event TEXT,  -- eclipse, meteor_shower, northern_lights, etc.
    biome_effects TEXT,  -- JSON: {biome_name: {modifier_type: value}}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_calendar_season ON world_calendar(season);
CREATE INDEX idx_calendar_day_number ON world_calendar(day_number DESC);
CREATE INDEX idx_calendar_weather ON world_calendar(weather_type);

-- ============================================================================
-- SEASONAL EVENTS & WORLD DYNAMICS (Phase 11C)
-- ============================================================================
CREATE TABLE IF NOT EXISTS seasonal_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_name TEXT NOT NULL,
    event_type TEXT,  -- 'harvest_festival', 'winter_storm', 'migration', 'eclipse', 'meteor_shower', 'creature_invasion', 'resource_boom'
    season TEXT,  -- 'spring', 'summer', 'autumn', 'winter', or 'any'
    day_of_year_range_start INTEGER,  -- Which day of calendar it occurs
    day_of_year_range_end INTEGER,
    duration_hours INTEGER DEFAULT 24,
    affected_biomes TEXT,  -- JSON array: ['temperate', 'arctic', 'desert', ...]
    affected_continents TEXT,  -- JSON array: ['story', 'sandbox', 'pvp', ...]
    resource_availability_modifiers TEXT,  -- JSON: {resource_type: multiplier}
    economy_impact TEXT,  -- 'inflation', 'deflation', 'supply_shortage', 'demand_spike', 'neutral'
    economy_impact_percentage REAL DEFAULT 0.0,  -- ±percentage for prices
    player_engagement_reward_bonus REAL DEFAULT 1.0,  -- 1.0 = normal, 2.0 = double rewards
    npc_behavior_modifiers TEXT,  -- JSON: NPC behavior changes during event
    event_description TEXT,
    is_repeating BOOLEAN DEFAULT 1,
    enabled BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_events_season ON seasonal_events(season);
CREATE INDEX idx_events_type ON seasonal_events(event_type);
CREATE INDEX idx_events_enabled ON seasonal_events(enabled);

-- ============================================================================
-- EVENT OCCURRENCE TRACKING (Phase 11C)
-- ============================================================================
CREATE TABLE IF NOT EXISTS event_occurrences (
    occurrence_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id INTEGER NOT NULL,
    actual_start_timestamp TIMESTAMP,
    actual_end_timestamp TIMESTAMP,
    intensity_modifier REAL DEFAULT 1.0,  -- Actual strength vs baseline
    player_participation INTEGER DEFAULT 0,  -- How many players engaged
    event_outcome TEXT,  -- 'successful', 'failed', 'neutral', 'chaotic'
    world_impact_summary TEXT,
    next_occurrence_predicted TIMESTAMP,
    FOREIGN KEY(event_id) REFERENCES seasonal_events(event_id)
);

CREATE INDEX idx_occurrences_event ON event_occurrences(event_id);
CREATE INDEX idx_occurrences_timestamp ON event_occurrences(actual_start_timestamp DESC);

-- ============================================================================
-- PHASE 13A: WORLD EVENTS & AUCTION SYSTEM TABLES
-- ============================================================================
CREATE TABLE IF NOT EXISTS world_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_name TEXT NOT NULL,
    event_type TEXT NOT NULL,  -- invasion, plague, natural_disaster, festival, treasure_discovery, market_crash, etc.
    event_status TEXT DEFAULT 'planned',  -- planned, active, resolving, resolved, cancelled
    affected_continent TEXT,  -- story, sandbox, pvp
    severity INTEGER DEFAULT 5,  -- 1-10 scale
    event_description TEXT,
    affected_resources_json TEXT,  -- JSON: {resource_type: multiplier, ...}
    event_start_timestamp TIMESTAMP,
    activation_timestamp TIMESTAMP,
    event_end_timestamp TIMESTAMP,
    expected_duration_hours INTEGER,
    player_participation INTEGER DEFAULT 0,
    event_outcome TEXT,  -- TBD until resolved
    world_impact_summary TEXT,  -- Post-event analysis
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_events_continent ON world_events(affected_continent);
CREATE INDEX idx_events_status ON world_events(event_status);
CREATE INDEX idx_events_type ON world_events(event_type);
CREATE INDEX idx_events_start ON world_events(event_start_timestamp DESC);
CREATE INDEX idx_events_active ON world_events(event_status, event_start_timestamp);

-- ============================================================================
-- PHASE 13A: AUCTION SYSTEM TABLES
-- ============================================================================
CREATE TABLE IF NOT EXISTS auction_listings (
    listing_id INTEGER PRIMARY KEY AUTOINCREMENT,
    seller_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    item_quantity INTEGER DEFAULT 1,
    starting_bid INTEGER NOT NULL,
    current_bid INTEGER DEFAULT 0,
    highest_bidder_id INTEGER,  -- NULL if no bids yet
    auction_status TEXT DEFAULT 'active',  -- active, sold, unsold, cancelled
    auction_start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    auction_end_time TIMESTAMP,
    auction_duration_hours INTEGER DEFAULT 24,
    reserve_price INTEGER,  -- Minimum acceptable price (optional)
    buyout_price INTEGER,  -- Option to buy immediately at this price (optional)
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(seller_id) REFERENCES players(id) ON DELETE CASCADE,
    FOREIGN KEY(highest_bidder_id) REFERENCES players(id)
);

CREATE INDEX idx_auction_seller ON auction_listings(seller_id);
CREATE INDEX idx_auction_status ON auction_listings(auction_status);
CREATE INDEX idx_auction_item ON auction_listings(item_name);
CREATE INDEX idx_auction_end_time ON auction_listings(auction_end_time);
CREATE INDEX idx_auction_active ON auction_listings(auction_status, auction_end_time);

-- ============================================================================
-- PHASE 13A: AUCTION BIDS HISTORY TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS auction_bids (
    bid_id INTEGER PRIMARY KEY AUTOINCREMENT,
    listing_id INTEGER NOT NULL,
    bidder_id INTEGER NOT NULL,
    bid_amount INTEGER NOT NULL,
    bid_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_highest BOOLEAN DEFAULT 0,  -- Is this the current highest bid?
    FOREIGN KEY(listing_id) REFERENCES auction_listings(listing_id) ON DELETE CASCADE,
    FOREIGN KEY(bidder_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_bids_listing ON auction_bids(listing_id);
CREATE INDEX idx_bids_bidder ON auction_bids(bidder_id);
CREATE INDEX idx_bids_highest ON auction_bids(listing_id, is_highest);
CREATE INDEX idx_bids_timestamp ON auction_bids(bid_timestamp DESC);

-- ============================================================================
-- PHASE 13B: NPC MIGRATION ROUTES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS npc_migration_routes (
    route_id INTEGER PRIMARY KEY AUTOINCREMENT,
    route_name TEXT NOT NULL,
    origin_location_name TEXT NOT NULL,
    destination_location_name TEXT NOT NULL,
    origin_x INTEGER,
    origin_y INTEGER,
    origin_z INTEGER,
    destination_x INTEGER,
    destination_y INTEGER,
    destination_z INTEGER,
    route_distance_units REAL,  -- Approximate path length
    waypoints_json TEXT,  -- JSON array of intermediate waypoints: [{x, y, z}, ...]
    is_active BOOLEAN DEFAULT 1,
    danger_level INTEGER DEFAULT 0,  -- 0-10, affects travel time and NPC decisions
    traffic_volume INTEGER DEFAULT 0,  -- How many caravans use this route
    last_traffic_update TIMESTAMP,
    biome_types TEXT,  -- JSON array: ['temperate', 'arctic', ...] biomes the route crosses
    affected_continent TEXT,  -- story, sandbox, pvp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_routes_active ON npc_migration_routes(is_active);
CREATE INDEX idx_routes_continent ON npc_migration_routes(affected_continent);
CREATE INDEX idx_routes_origin ON npc_migration_routes(origin_location_name);
CREATE INDEX idx_routes_destination ON npc_migration_routes(destination_location_name);
CREATE INDEX idx_routes_danger ON npc_migration_routes(danger_level);

-- ============================================================================
-- PHASE 13B: SUPPLY CHAINS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS supply_chains (
    chain_id INTEGER PRIMARY KEY AUTOINCREMENT,
    route_id INTEGER NOT NULL,
    npc_id INTEGER,  -- NPC operating this caravan
    chain_status TEXT DEFAULT 'planned',  -- planned, in_transit, delayed, disrupted, delivered, failed
    cargo_items_json TEXT,  -- JSON: {item_name: quantity, ...}
    cargo_value_lucre INTEGER,  -- Total value in Lucre
    departure_timestamp TIMESTAMP,
    expected_arrival_timestamp TIMESTAMP,
    actual_arrival_timestamp TIMESTAMP,
    current_location_x INTEGER,
    current_location_y INTEGER,
    current_location_z INTEGER,
    disruption_reason TEXT,  -- If disrupted: bandits, weather, accident, etc.
    profit_earned INTEGER DEFAULT 0,  -- After delivery
    losses_incurred INTEGER DEFAULT 0,  -- From disruptions
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(route_id) REFERENCES npc_migration_routes(route_id),
    FOREIGN KEY(npc_id) REFERENCES npc_persistent_state(npc_id)
);

CREATE INDEX idx_chains_route ON supply_chains(route_id);
CREATE INDEX idx_chains_npc ON supply_chains(npc_id);
CREATE INDEX idx_chains_status ON supply_chains(chain_status);
CREATE INDEX idx_chains_departure ON supply_chains(departure_timestamp DESC);
CREATE INDEX idx_chains_active ON supply_chains(chain_status, expected_arrival_timestamp);

-- ============================================================================
-- PHASE 13B: TRADE ROUTE PRICE VARIATIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS route_price_variations (
    variation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    route_id INTEGER NOT NULL,
    resource_type TEXT NOT NULL,
    origin_price REAL,  -- Price at starting location
    destination_price REAL,  -- Price at ending location
    price_difference_percent REAL,  -- (destination - origin) / origin * 100
    profit_margin REAL,  -- Expected profit for this leg
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(route_id) REFERENCES npc_migration_routes(route_id),
    UNIQUE(route_id, resource_type)
);

CREATE INDEX idx_variation_route ON route_price_variations(route_id);
CREATE INDEX idx_variation_resource ON route_price_variations(resource_type);
CREATE INDEX idx_variation_margin ON route_price_variations(profit_margin DESC);

-- ============================================================================
-- PHASE 13C: MARKET CYCLES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS market_cycles (
    cycle_id INTEGER PRIMARY KEY AUTOINCREMENT,
    affected_resource TEXT NOT NULL,  -- Which resource this cycle affects
    cycle_type TEXT NOT NULL,  -- boom, bubble, crash, recovery, stagnation
    cycle_status TEXT DEFAULT 'active',  -- active, completed, interrupted
    cycle_start_timestamp TIMESTAMP,
    cycle_peak_timestamp TIMESTAMP,
    expected_cycle_end_timestamp TIMESTAMP,
    actual_cycle_end_timestamp TIMESTAMP,
    price_change_percentage REAL,  -- % change from start to peak (can be negative)
    price_volatility REAL DEFAULT 0.1,  -- How erratic price changes are
    duration_hours INTEGER,  -- Expected cycle duration
    intensity_multiplier REAL DEFAULT 1.0,  -- Strength of the cycle effect
    contributing_factors_json TEXT,  -- JSON array of factors: ["supply_shortage", "demand_spike", ...]
    player_impact_summary TEXT,  -- Description of player impact
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cycles_resource ON market_cycles(affected_resource);
CREATE INDEX idx_cycles_type ON market_cycles(cycle_type);
CREATE INDEX idx_cycles_status ON market_cycles(cycle_status);
CREATE INDEX idx_cycles_start ON market_cycles(cycle_start_timestamp DESC);
CREATE INDEX idx_cycles_active ON market_cycles(cycle_status, affected_resource);

-- ============================================================================
-- PHASE 13C: ECONOMIC INDICATORS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS economic_indicators (
    indicator_id INTEGER PRIMARY KEY AUTOINCREMENT,
    resource_type TEXT UNIQUE NOT NULL,
    price_change_24h_percent REAL DEFAULT 0.0,  -- Price % change in last 24h
    price_change_7d_percent REAL DEFAULT 0.0,  -- Price % change in last 7d
    supply_level INTEGER DEFAULT 0,  -- 0-100, where 0=empty, 100=abundant
    demand_level INTEGER DEFAULT 50,  -- 0-100
    volatility_index REAL DEFAULT 0.5,  -- 0-1 scale
    trend TEXT DEFAULT 'stable',  -- rising, falling, stable, chaotic
    trend_strength INTEGER DEFAULT 0,  -- 0-100 confidence in trend
    bubble_risk_score REAL DEFAULT 0.0,  -- 0-1 chance of bubble forming
    crash_risk_score REAL DEFAULT 0.0,  -- 0-1 chance of crash
    scarcity_alert_active BOOLEAN DEFAULT 0,  -- Is item scarce?
    inflation_contributor BOOLEAN DEFAULT 0,  -- Does this item contribute to inflation?
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(resource_type) REFERENCES market_prices(commodity_name)
);

CREATE INDEX idx_indicators_resource ON economic_indicators(resource_type);
CREATE INDEX idx_indicators_trend ON economic_indicators(trend);
CREATE INDEX idx_indicators_bubble_risk ON economic_indicators(bubble_risk_score DESC);
CREATE INDEX idx_indicators_crash_risk ON economic_indicators(crash_risk_score DESC);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
