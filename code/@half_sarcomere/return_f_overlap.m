function f_overlap = return_f_overlap(obj)
% Function returns f_overlap
f_overlap=[];
x_no_overlap = obj.hs_length - obj.myofilaments.thick_filament_length;
x_overlap = obj.myofilaments.thin_filament_length - x_no_overlap;
max_x_overlap = obj.myofilaments.thick_filament_length -  ...
    obj.myofilaments.bare_zone_length;

%%SNS added || x_overlap==0
if (x_overlap<0 || x_overlap==0)
    f_overlap=0;
end

if ((x_overlap>0)&(x_overlap<=max_x_overlap))
    f_overlap = x_overlap/max_x_overlap;
end

if (x_overlap>max_x_overlap)
    f_overlap=1;
end

protrusion = obj.myofilaments.thin_filament_length - ...
    (obj.hs_length + obj.myofilaments.bare_zone_length);

if (protrusion > 0)
    x_overlap = (max_x_overlap - protrusion);
    f_overlap = x_overlap / max_x_overlap;
end

if isempty(f_overlap)
    dbstop in return_f_overlap at 31
end