-- Generate random discount data function
CREATE OR REPLACE PROCEDURE gen_discount() AS $$
BEGIN
    WHILE (SELECT count(id) FROM discount) < 20 LOOP
        WITH choice AS (SELECT '{free, percentage, fixed, other}'::VARCHAR[] a)
        INSERT INTO discount (type, amt, start_date, end_date)
        VALUES (
            (SELECT a[1 + floor((random() * array_length(a, 1)))::int] FROM choice),
            (SELECT floor(random() * 99)),
            (SELECT now() - (random() * (interval '3 months'))),
            (SELECT now() + (random() * (interval '3 months')))
        );
    END LOOP;
END;
$$ LANGUAGE PLPGSQL;
CALL gen_discount();


CREATE OR REPLACE FUNCTION fix_discount_amt() RETURNS trigger AS $$
BEGIN
    NEW.amt = 0;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION archive_item() RETURNS trigger AS $$
DECLARE
    comparison BOOLEAN = FALSE;
BEGIN
    FOR i IN 1..(TG_NARGS - 1) LOOP
        EXECUTE format('SELECT $1.%1$I <> $2.%1$I;', TG_ARGV[i]) INTO STRICT comparison USING OLD, NEW;
        IF comparison THEN
            EXECUTE format('INSERT INTO item_archive (id, attribute_name, old_value, new_value, archive_time) '
                'VALUES ($1.id, %1$L, $1.%1$I::VARCHAR, $2.%1$I::VARCHAR, current_timestamp);', TG_ARGV[i]) USING OLD, NEW;
        END IF;
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;
