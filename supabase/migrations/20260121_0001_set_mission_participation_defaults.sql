-- Create a trigger function to set default award_points and cost for mission_participation
CREATE OR REPLACE FUNCTION set_mission_participation_defaults()
RETURNS TRIGGER AS $$
BEGIN
    -- Get award_points and cost from the related mission
    SELECT award_points, cost INTO NEW.award_points, NEW.cost
    FROM mission
    WHERE id = NEW.mission;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a function to handle awarding points on mission participation approval
CREATE OR REPLACE FUNCTION award_points_on_approval()
RETURNS TRIGGER AS $$
DECLARE
    current_balance numeric;
    award_amt numeric;
BEGIN
    -- Only proceed if approved_at was null and is now not null
    IF OLD.approved_at IS NULL AND NEW.approved_at IS NOT NULL THEN
        -- Get current balance
        SELECT COALESCE(points, 0) INTO current_balance
        FROM award_points
        WHERE "user" = NEW.participated_by;
        
        -- Get award amount
        award_amt := COALESCE(NEW.award_points, 0);
        
        -- Insert transaction
        INSERT INTO award_points_transaction (
            created_by,
            transaction_by,
            award_amount,
            previous_amount,
            new_amount,
            awarded_user,
            related_participation
        ) VALUES (
            NEW.approved_by,
            NEW.approved_by,
            award_amt,
            current_balance,
            current_balance + award_amt,
            NEW.participated_by,
            NEW.id
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger that runs after update on mission_participation
CREATE TRIGGER trigger_award_points_on_approval
    AFTER UPDATE ON mission_participation
    FOR EACH ROW EXECUTE FUNCTION award_points_on_approval();

-- Create a function to get total approved participations count
CREATE OR REPLACE FUNCTION get_total_approved_participations()
RETURNS bigint AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM mission_participation WHERE approved_at IS NOT NULL);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a function to get sum of award_points from approved participations
CREATE OR REPLACE FUNCTION get_total_award_points_from_approved_participations()
RETURNS numeric AS $$
BEGIN
    RETURN COALESCE((SELECT SUM(award_points) FROM mission_participation WHERE approved_at IS NOT NULL), 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;