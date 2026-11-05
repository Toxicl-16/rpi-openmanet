'use strict';
/* globals E */
'require view';
'require rpc';
'require ui';

var callRepair = rpc.declare({
	object: 'openmanet-batman',
	method: 'repair',
	params: [],
	expect: { '': { ok: false } }
});

return view.extend({
	render: function() {
		var button = E('button', {
			'class': 'cbi-button cbi-button-action',
			'click': function() {
				button.disabled = true;
				return callRepair().then(function(result) {
					if (!result || !result.ok)
						throw new Error(_('The BATMAN repair command failed.'));

					ui.addNotification(null,
						E('p', _('BATMAN topology repaired. Wireless networking is reloading.')),
						'info');
				}).catch(function(error) {
					ui.addNotification(null,
						E('p', error.message || _('The BATMAN repair command failed.')),
						'error');
				}).then(function() {
					button.disabled = false;
				});
			},
		}, _('Repair BATMAN topology'));

		return E('div', { 'class': 'cbi-map' }, [
			E('h2', _('BATMAN-V repair')),
			E('p', _('Run this after the 802.11s mesh wizard if bat0 is missing or the HaLow mesh was placed directly on the bridge. The command restores the BATMAN-V interface chain and reloads networking.')),
			E('p', { 'class': 'alert-message warning' }, _('The network may briefly disconnect while wireless networking reloads.')),
			button
		]);
	}
});
