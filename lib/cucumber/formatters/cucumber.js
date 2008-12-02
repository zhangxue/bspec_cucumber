function stepPassed(id) {
  $("#"+id).removeClass("new").addClass("passed");
}

function stepPending(id) {
  $("#"+id).removeClass("new").addClass("pending");
}

function stepFailed(id, message, backtrace) {
  $("#"+id).removeClass("new").addClass("failed").append("<div>" + message + "</div>").append("<pre>" + backtrace + "</pre>");
}

function passed(id) {
  $("#"+id).removeClass("new").addClass("passed");
}

function pending(id) {
  $("#"+id).removeClass("new").addClass("pending");
}

function failed(id, message, backtrace) {
  $("#"+id).removeClass("new").addClass("failed");
  if(message != undefined){
    $("#"+id).append("<div>" + message + "</div>").append("<pre>" + backtrace + "</pre>");
  }
}

function add_scenario_case_id(id, case_id) {
  $("#"+id).html(case_id);
}

function add_scenario_case_name(scenario_id, case_name) {
  $("#scenario_case_name_"+scenario_id).html(case_name);
}