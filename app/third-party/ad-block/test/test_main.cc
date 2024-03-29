/*
    SPDX-License-Identifier: MPL-2.0
*/

/* Copyright (c) 2015 Brian R. Bondy. Distributed under the MPL2 license.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <string>
#include "./CppUnitLite/TestHarness.h"
#include "./util.h"

SimpleString StringFrom(const std::string& value) {
    return SimpleString(value.c_str());
}

int main() {
  TestResult tr;
  TestRegistry::runAllTests(tr);
  return 0;
}
