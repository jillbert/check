$(document).ready(function() {
  initializeSyncRsvpList();
})

function initializeSyncRsvpList() {
  // DataTable
  table = $('#synclist').DataTable({
    "order": [[ 0, 'asc' ]],
    "paging": false
  });
}
