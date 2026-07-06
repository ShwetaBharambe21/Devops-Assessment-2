CREATE EXTENSION IF NOT EXISTS "pgcrypto";

INSERT INTO hotel_bookings (
    id,
    org_id,
    hotel_id,
    city,
    checkin_date,
    checkout_date,
    amount,
    status,
    created_at
)
SELECT
    gen_random_uuid(),
    gen_random_uuid(),
    'HOTEL-' || (random()*20)::int,

    (
        ARRAY[
            'delhi',
            'mumbai',
            'pune',
            'bangalore',
            'hyderabad'
        ]
    )[floor(random()*5+1)],

    CURRENT_DATE + (random()*20)::int,

    CURRENT_DATE + (random()*30+21)::int,

    ROUND((random()*9000+1000)::numeric,2),

    (
        ARRAY[
            'confirmed',
            'pending',
            'cancelled'
        ]
    )[floor(random()*3+1)],

    NOW() - (random()*30 || ' days')::interval

FROM generate_series(1,100);


INSERT INTO booking_events (
    booking_id,
    event_type,
    payload,
    created_at
)
SELECT
    id,

    (
        ARRAY[
            'created',
            'payment',
            'checked_in',
            'checked_out'
        ]
    )[floor(random()*4+1)],

    '{}'::jsonb,

    NOW()

FROM hotel_bookings
LIMIT 60;