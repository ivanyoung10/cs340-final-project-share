-- SELECT trigger_catalog, trigger_name, event_manipulation, event_object_table FROM information_schema.triggers;
CREATE TRIGGER discount_amt_correction
BEFORE INSERT OR UPDATE OF type ON discount
FOR EACH ROW WHEN (NEW.type = 'free')
EXECUTE FUNCTION fix_discount_amt();

CREATE OR REPLACE TRIGGER item_update 
BEFORE UPDATE ON item
FOR EACH ROW 
EXECUTE FUNCTION archive_item('id', 'type', 'name', 'description', 'price', 'picture');
