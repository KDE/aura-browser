/**
 * SPDX-FileCopyrightText: 2022 Aditya Mehra
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

var element = document.getElementsByTagName("INPUT"); var index; for(var index = 0; index < element.length; index++) {element[index].onfocus = function(){console.log(JSON.stringify({"inputFocus": "GotInput", "className": document.activeElement.form.className, "id": document.activeElement.id}))}};
