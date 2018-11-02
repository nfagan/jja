function labs = add_drug_labels(labs, mask)

if ( nargin < 2 ), mask = rowmask( labs ); end

ot_days = { '0215', '0221', '0223', '0228', '0302', '0305' };
sal_days = { '0216', '0220', '0222', '0227', '0301' };

ot_ind = findor( labs, ot_days, mask );
sal_ind = findor( labs, sal_days, mask );

addcat( labs, 'drug' );
setcat( labs, 'drug', 'oxytocin', ot_ind );
setcat( labs, 'drug', 'saline', sal_ind );

prune( labs );

end