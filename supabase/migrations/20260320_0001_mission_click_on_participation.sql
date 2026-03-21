-- On participation insert: set award_points/cost from mission, and link an
-- existing unlinked mission_click (created on tile tap).
CREATE OR REPLACE FUNCTION set_mission_participation_defaults()
RETURNS TRIGGER AS $$
DECLARE
    v_mission_cost double precision;
    v_mission_award_points double precision;
    v_click_id uuid;
BEGIN
    -- Get award_points and cost from the related mission
    SELECT award_points, cost INTO v_mission_award_points, v_mission_cost
    FROM mission
    WHERE id = NEW.mission;

    NEW.award_points := v_mission_award_points;
    NEW.cost := v_mission_cost;

    -- Try to find an existing unlinked click for this user + mission
    SELECT mc.id INTO v_click_id
    FROM mission_click mc
    WHERE mc.mission = NEW.mission
      AND mc."user" = NEW.participated_by
      AND NOT EXISTS (
        SELECT 1 FROM mission_participation mp
        WHERE mp.mission_click = mc.id
      )
    ORDER BY mc.created_at DESC
    LIMIT 1;

    NEW.mission_click := v_click_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
