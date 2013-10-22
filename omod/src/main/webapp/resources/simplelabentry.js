
function getPatientAddress(patientId) {
	$j.getJSON(contextPath + "/module/addresshierarchyrwanda/patientAddress.form", {
		patientId :patientId
	}, function(data) {
		var count = -1;
		$j.each(data.addresses, function(i, address) {
			count++;
			$j("#cnt_" + count).val(address.country);
			$j("#sp_" + count).val(address.stateProvince);
			$j("#cd_" + count).val(address.countyDistrict);
			$j("#cv_" + count).val(address.cityVillage);
			$j("#nc_" + count).val(address.neighborhoodCell);
			$j("#a1_" + count).val(address.address1);
			$j("#structured_" + count).text(address.structured);
		});

	});
}

function changeLocation(parentLocationId, nextElement) {
	var locIdString = "" + parentLocationId;
	var parsedParentLocationId = locIdString.substring(3);
	$j.getJSON(contextPath + "/module/addresshierarchyrwanda/locations.form", {
		locationId :parsedParentLocationId
	}, function(data) {
		nextElement.append($j(document.createElement("option")).text("--"));
		$j.each(data.addresses, function(i, address) {

			nextElement.append($j(document.createElement("option")).attr(
					"value", "ah_" + address.id).text(address.display).attr(
					"id", "ah_" + address.id));
		});

	});
}

function validateSingleAddress(someElement,country, province, district, sector, cell, umudugudu){
	$j.getJSON(openmrsContextPath+"/module/addresshierarchyrwanda/ahValidateAddress.form", {
		country:country,
		province:province,
		district:district,
		sector:sector,
		cell:cell,
		umudugudu:umudugudu
	}, function(data) {
			$j.each(data.values, function(i, value) {
				if(value.value == 1){
					$j(someElement).empty();
					$j(someElement).append($j(document.createElement("img")).attr("src",openmrsContextPath+"/images/checkmark.png"));
				}else{
					$j(someElement).empty();
					$j(someElement).append($j(document.createElement("img")).attr("src",openmrsContextPath+"/images/error.gif"));
				}
			});
		});
}


function validateAddressesOnPage(){
	
	var structuredElements = $j(".isstructured");
	var country, province, district, sector, cell, umudugudu;
	
	for(var i = 0; i < structuredElements.length; i++){
		
//		var td = $j(structuredElements[i]).closest("table")
//		.children("tbody")
//		.children("tr")
//		.children("td");
		
//		country = $j(td).children(".countrySaveClass").val();
//		province = $j(td).children(".provinceSaveClass").val();
//		district = $j(td).children(".districtSaveClass").val();
//		sector = $j(td).children(".sectorSaveClass").val();
//		cell = $j(td).children(".cellSaveClass").val();
//		umudugudu = $j(td).children(".address1SaveClass").val();
		
		country = getSiblingWithinValueFromClass(structuredElements[i],"countrySaveClass");
		province = getSiblingWithinValueFromClass(structuredElements[i],"provinceSaveClass");
		district = getSiblingWithinValueFromClass(structuredElements[i],"districtSaveClass");
		sector = getSiblingWithinValueFromClass(structuredElements[i],"sectorSaveClass");
		cell = getSiblingWithinValueFromClass(structuredElements[i],"cellSaveClass");
		umudugudu = getSiblingWithinValueFromClass(structuredElements[i],"address1SaveClass");
		
		validateSingleAddress(structuredElements[i],country, province, district, sector, cell, umudugudu);

	}
}

function getSiblingWithinValueFromClass(someElement,className){
	
	var td = $j(someElement).closest("table")
	.children("tbody")
	.children("tr")
	.children("td");
	//alert("returning " + $j(td).children("."+className).val());
	return $j(td).children("."+className).val()
}

function getSiblingWithinTableFromClass(someElement,className){
	
	var td = $j(someElement).closest("table")
	.children("tbody")
	.children("tr")
	.children("td");
	return $j(td).children("."+className);
}

function validateAddressOnChange(targetElement){
	
	var structuredElement = getSiblingWithinTableFromClass(targetElement,"isstructured");
	
	var country = getSiblingWithinValueFromClass(structuredElement,"countrySaveClass");
	var province = getSiblingWithinValueFromClass(structuredElement,"provinceSaveClass");
	var district = getSiblingWithinValueFromClass(structuredElement,"districtSaveClass");
	var sector = getSiblingWithinValueFromClass(structuredElement,"sectorSaveClass");
	var cell = getSiblingWithinValueFromClass(structuredElement,"cellSaveClass");
	var umudugudu = getSiblingWithinValueFromClass(structuredElement,"address1SaveClass");
	validateSingleAddress(structuredElement, country, province, district, sector, cell, umudugudu);
}


$j(document).ready(

		function() {
			
			$j(".countryClass").live(
					"change",
					function() {
						// alert("country visible change handler");
						$j(".provinceClass:visible").children().remove();
						$j(".districtClass:visible").children().remove();
						$j(".sectorClass:visible").children().remove();
						$j(".cellClass:visible").children().remove();
						$j(".address1Class:visible").children().remove();

						if ($j(this).val() != "--") {
							changeLocation($j(this).val(),
									$j(".provinceClass:visible"));
							$j(".countrySaveClass:visible").val(
									$j(this).children(":selected").text());
						}
						validateAddressOnChange(this);
					});

			$j(".provinceClass").live(
					"change",
					function() {
						$j(".districtClass:visible ").children().remove();
						$j(".sectorClass:visible ").children().remove();
						$j(".cellClass:visible").children().remove();
						$j(".address1Class:visible").children().remove();
						if ($j(this).val() != "--") {
							changeLocation($j(this).val(),
									$j(".districtClass:visible"));
							$j(".provinceSaveClass:visible").val(
									$j(this).children(":selected").text());
						}
						validateAddressOnChange(this);
					});

			$j(".districtClass").live(
					"change",
					function() {
						
						$j(".sectorClass:visible").children().remove();
						$j(".cellClass:visible").children().remove();
						$j(".address1Class:visible").children().remove();
						if ($j(this).val() != "--") {
							changeLocation($j(this).val(),
									$j(".sectorClass:visible"));
							$j(".districtSaveClass:visible").val(
									$j(this).children(":selected").text());
						}
						validateAddressOnChange(this)
					});

			$j(".sectorClass").live(
					"change",
					function() {
						$j(".cellClass:visible").children().remove();
						$j(".address1Class:visible").children().remove();
						if ($j(this).val() != "--") {
							changeLocation($j(this).val(),
									$j(".cellClass:visible"));
							$j(".sectorSaveClass:visible").val(
									$j(this).children(":selected").text());
						}
						validateAddressOnChange(this)
					});

			$j(".cellClass").live(
					"change",
					function() {
						$j(".address1Class:visible").children().remove();
						if ($j(this).val() != "--") {
							changeLocation($j(this).val(),
									$j(".address1Class:visible"));
							$j(".cellSaveClass:visible").val(
									$j(this).children(":selected").text());
						}
						validateAddressOnChange(this)
					});

			$j(".address1Class").live(
					"change",
					function() {
						
						if ($j(this).val() != "--") {
							$j(".address1SaveClass:visible").val(
									$j(this).children(":selected").text());
						}
						validateAddressOnChange(this);
					});
			
			
			
			
			// ===================== handlers for changes in the text box ================== //
			$j(".address1SaveClass").live(
					"keyup",
					function() {
						validateAddressOnChange(this);
					});
			
			$j(".cellSaveClass").live(
					"keyup",
					function() {
						validateAddressOnChange(this);
					});
			
			$j(".sectorSaveClass").live(
					"keyup",
					function() {
						validateAddressOnChange(this);
					});
			$j(".districtSaveClass").live(
					"keyup",
					function() {
						validateAddressOnChange(this);
					});

			$j(".provinceSaveClass").live(
					"keyup",
					function() {
						validateAddressOnChange(this);
					});
			$j(".countrySaveClass").live(
					"keyup",
					function() {
						validateAddressOnChange(this);
					});
			
			
			changeLocation(-1, $j(".countryClass"));
			validateAddressesOnPage();
			
			
			/**var anyCountry = $j(".isstructuredclass").
				closest("table")
				.children("tbody")
				.children("tr")
				.children("td")
				.children(".countrySaveClass").val();
				alert(anyCountry);
				
			var anyCountry = $j(".isstructuredclass").
				closest("table")
				.children("tbody")
				.children("tr")
				.children("td")
				.children(".provinceSaveClass").val();
				alert(anyCountry);
			
			var anyCountry = $j(".isstructuredclass").
				closest("table")
				.children("tbody")
				.children("tr")
				.children("td")
				.children(".districtSaveClass").val();
				alert(anyCountry);
				
			var anyCountry = $j(".isstructuredclass").
				closest("table")
				.children("tbody")
				.children("tr")
				.children("td")
				.children(".sectorSaveClass").val();
				alert(anyCountry);
				
			var anyCountry = $j(".isstructuredclass").
				closest("table")
				.children("tbody")
				.children("tr")
				.children("td")
				.children(".cellSaveClass").val();
				alert(anyCountry);
				
			var anyCountry = $j(".isstructuredclass").
				closest("table")
				.children("tbody")
				.children("tr")
				.children("td")
				.children(".address1SaveClass").val();
				alert(anyCountry);
				**/
//				var country = $j(".countrySaveClass:visible").val();
//				var province = $j(".provinceSaveClass:visible").val();
//				var district = $j(".districtSaveClass:visible").val();
//				var sector = $j(".sectorSaveClass:visible").val();
//				var cell = $j(".cellSaveClass:visible").val();
//				var umudugudu = $j(".address1SaveClass:visible").val();
//			
			
			$j(".voided").live(
					"change",
					function() {
						var voidedReasonRow = $j(this).closest("table")
								.siblings("table").children("tbody").children(
										".voidedReasonRowClass");
						if (voidedReasonRow.css("display") == "none") {
							voidedReasonRow.show("fast");
						} else {
							voidedReasonRow.hide("fast");
						}
					});

			
		});