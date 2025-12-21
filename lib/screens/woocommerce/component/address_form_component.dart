import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/woo_commerce/billing_address_model.dart';
import 'package:kivicare_flutter/model/woo_commerce/country_model.dart';
import 'package:kivicare_flutter/screens/woocommerce/screens/edit_shop_detail_screen.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:nb_utils/nb_utils.dart';

class AddressFormComponent extends StatefulWidget {
  final BillingAddressModel? data;
  final bool isBilling;
  final GlobalKey<FormState>? formKey;

  const AddressFormComponent({Key? key, this.data, this.isBilling = false, this.formKey}) : super(key: key);

  @override
  State<AddressFormComponent> createState() => _AddressFormComponentState();
}

List<CountryModel> countriesList = [];

class _AddressFormComponentState extends State<AddressFormComponent> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController company = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController addOne = TextEditingController();
  TextEditingController addTwo = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController postCode = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode companyFocus = FocusNode();
  FocusNode addOneFocus = FocusNode();
  FocusNode addTwoFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode postCodeFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  CountryModel? selectedCountry;
  StateModel? selectedState;
  String selectedCountryCode = '+91';

  List<CountryModel> countries = [];

  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    String res = getStringAsync(SharedPreferenceKey.countriesListKey);
    if (res.isNotEmpty) {
      countries.addAll((jsonDecode(res) as List).map((e) => CountryModel.fromJson(e)).toList());
    }
    if (widget.data != null) {
      firstName.text = widget.data!.firstName.validate();
      lastName.text = widget.data!.lastName.validate();
      company.text = widget.data!.company.validate();
      country.text = widget.data!.country.validate();
      addOne.text = widget.data!.address_1.validate();
      city.text = widget.data!.city.validate();
      state.text = widget.data!.state.validate();
      postCode.text = widget.data!.postcode.validate();
      phone.text = widget.data!.phone.validate();
      if (phone.text.isNotEmpty) {
        // Find matching code from available list
        List<String> codes = ['+1', '+44', '+91', '+971', '+61'];

        selectedCountryCode = codes.firstWhere(
          (c) => phone.text.startsWith(c),
          orElse: () => '+91',
        );

        // Remove prefix for textfield
        phone.text = phone.text.replaceFirst(selectedCountryCode, '');
      }
      email.text = widget.data!.email.validate();
      if (widget.data!.country.validate().isNotEmpty) {
        if (countriesList.any((element) => element.name == widget.data!.country.validate())) {
          selectedCountry = countriesList.firstWhere((element) => element.name == widget.data!.country.validate());
        }
        if (selectedCountry != null && selectedCountry!.states != null) {
          if (widget.data!.state.validate().isNotEmpty) {
            if (selectedCountry!.states.validate().any((element) => element.name == widget.data!.state.validate())) selectedState = selectedCountry!.states.validate().firstWhere((element) => element.name == widget.data!.state.validate());
          }
        }
      } else {
        selectedCountry = null;
        selectedState = null;
      }
    }

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  void validateAndSaveForm() {
    if (widget.formKey?.currentState?.validate() ?? false) {
      widget.formKey?.currentState?.save();
    } else {
      isFirstTime = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: UniqueKey(),
      child: Form(
        key: widget.formKey,
        autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            16.height,
            Row(
              children: [
                AppTextField(
                  textStyle: primaryTextStyle(),
                  controller: firstName,
                  textFieldType: TextFieldType.NAME,
                  focus: firstNameFocus,
                  errorThisFieldRequired: locale.lblFirstNameIsRequired,
                  nextFocus: lastNameFocus,
                  decoration: inputDecoration(context: context, labelText: locale.lblFirstName, fillColor: context.scaffoldBackgroundColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '${locale.lblFirstName} ${locale.lblIsRequired}';
                    }
                    return null;
                  },
                  onChanged: (text) {
                    if (widget.isBilling) {
                      billingAddress.firstName = text;
                    } else {
                      shippingAddress.firstName = text;
                    }
                  },
                  onFieldSubmitted: (text) {
                    if (widget.isBilling) {
                      billingAddress.firstName = text;
                    } else {
                      shippingAddress.firstName = text;
                    }
                  },
                ).expand(),
                16.width,
                AppTextField(
                  textStyle: primaryTextStyle(),
                  controller: lastName,
                  textFieldType: TextFieldType.NAME,
                  focus: lastNameFocus,
                  nextFocus: companyFocus,
                  errorThisFieldRequired: locale.lblLastNameIsRequired,
                  decoration: inputDecoration(context: context, labelText: locale.lblLastName, fillColor: context.scaffoldBackgroundColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '${locale.lblLastName} ${locale.lblIsRequired}';
                    }
                    return null;
                  },
                  onChanged: (text) {
                    if (widget.isBilling) {
                      billingAddress.lastName = text;
                    } else {
                      shippingAddress.lastName = text;
                    }
                  },
                  onFieldSubmitted: (text) {
                    if (widget.isBilling) {
                      billingAddress.lastName = text;
                    } else {
                      shippingAddress.lastName = text;
                    }
                  },
                ).expand(),
              ],
            ),
            16.height,
            AppTextField(
              enabled: !appStore.isLoading,
              controller: company,
              focus: companyFocus,
              nextFocus: addOneFocus,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              textFieldType: TextFieldType.NAME,
              textStyle: primaryTextStyle(),
              maxLines: 1,
              decoration: inputDecoration(
                context: context,
                labelText: locale.lblCompany,
                fillColor: context.scaffoldBackgroundColor,
              ),
              onChanged: (text) {
                if (widget.isBilling) {
                  billingAddress.company = text;
                } else {
                  shippingAddress.company = text;
                }
              },
              onFieldSubmitted: (text) {
                if (widget.isBilling) {
                  billingAddress.company = text;
                } else {
                  shippingAddress.company = text;
                }
              },
            ),
            16.height,
            AppTextField(
              enabled: !appStore.isLoading,
              controller: addOne,
              focus: addOneFocus,
              nextFocus: addTwoFocus,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              textFieldType: TextFieldType.NAME,
              textStyle: primaryTextStyle(),
              maxLines: 1,
              decoration: inputDecoration(
                context: context,
                labelText: '${locale.lblAddress} 1',
                fillColor: context.scaffoldBackgroundColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '${locale.lblAddress} ${locale.lblIsRequired}';
                }
                return null;
              },
              onChanged: (text) {
                if (widget.isBilling) {
                  billingAddress.address_1 = text;
                } else {
                  shippingAddress.address_1 = text;
                }
              },
              onFieldSubmitted: (text) {
                if (widget.isBilling) {
                  billingAddress.address_1 = text;
                } else {
                  shippingAddress.address_1 = text;
                }
              },
            ),
            16.height,
            AppTextField(
              isValidationRequired: false,
              enabled: !appStore.isLoading,
              controller: addTwo,
              focus: addTwoFocus,
              nextFocus: countryFocus,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              textFieldType: TextFieldType.NAME,
              textStyle: primaryTextStyle(),
              maxLines: 1,
              decoration: inputDecoration(
                context: context,
                labelText: '${locale.lblAddress} 2',
                fillColor: context.scaffoldBackgroundColor,
              ),
              onChanged: (text) {
                if (widget.isBilling) {
                  billingAddress.address_2 = text;
                } else {
                  shippingAddress.address_2 = text;
                }
              },
              onFieldSubmitted: (text) {
                if (widget.isBilling) {
                  billingAddress.address_2 = text;
                } else {
                  shippingAddress.address_2 = text;
                }
              },
            ),
            16.height,
            DropdownButtonFormField(
              isExpanded: true,
              borderRadius: radius(),
              dropdownColor: context.cardColor,
              decoration: inputDecoration(
                context: context,
                labelText: locale.lblCountry,
                fillColor: context.scaffoldBackgroundColor,
              ),
              initialValue: selectedCountry,
              validator: (value) {
                if (value == null) {
                  return '${locale.lblCountry} ${locale.lblIsRequired}';
                }
                return null;
              },
              items: countriesList
                  .map(
                    (country) => DropdownMenuItem(
                      value: country,
                      child: Text(country.name.validate(), style: secondaryTextStyle()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                selectedCountry = value;
                setState(() {});
                if (widget.isBilling) {
                  billingAddress.country = value!.name;
                } else {
                  shippingAddress.country = value!.name;
                }
              },
            ),
            16.height,
            Row(
              children: [
                AppTextField(
                  controller: city,
                  focus: cityFocus,
                  nextFocus: postCodeFocus,
                  textInputAction: TextInputAction.next,
                  textFieldType: TextFieldType.OTHER,
                  decoration: inputDecoration(
                    context: context,
                    labelText: locale.lblCity,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '${locale.lblCity} ${locale.lblIsRequired}';
                    }
                    return null;
                  },
                  onFieldSubmitted: (text) {
                    if (widget.isBilling) {
                      billingAddress.city = text;
                    } else {
                      shippingAddress.city = text;
                    }
                  },
                  onChanged: (text) {
                    if (widget.isBilling) {
                      billingAddress.city = text;
                    } else {
                      shippingAddress.city = text;
                    }
                  },
                ).expand(),
                16.width,
                AppTextField(
                  controller: postCode,
                  focus: postCodeFocus,
                  nextFocus: phoneFocus,
                  textFieldType: TextFieldType.OTHER,
                  textInputAction: TextInputAction.next,
                  decoration: inputDecoration(
                    context: context,
                    labelText: locale.lblPostalCode,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '${locale.lblPostalCode} ${locale.lblIsRequired}';
                    }
                    return null;
                  },
                  onChanged: (text) {
                    if (widget.isBilling) {
                      billingAddress.postcode = text;
                    } else {
                      shippingAddress.postcode = text;
                    }
                  },
                  onFieldSubmitted: (text) {
                    if (widget.isBilling) {
                      billingAddress.postcode = text;
                    } else {
                      shippingAddress.postcode = text;
                    }
                  },
                ).expand()
              ],
            ),
            16.height,
            Row(
              children: [
                // Country Code Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedCountryCode,
                  isExpanded: true,
                  borderRadius: radius(),
                  dropdownColor: context.cardColor,
                  decoration: inputDecoration(
                    context: context,
                    labelText: locale.lblCountry,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                  items: countriesList
                      .map((country) => DropdownMenuItem<String>(
                            value: country.dial_code,
                            child: Text(
                              '${country.dial_code} (${country.code})',
                              style: secondaryTextStyle(),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCountryCode = value ?? '+91';
                    });

                    if (widget.isBilling) {
                      billingAddress.phone = '$selectedCountryCode${phone.text}';
                    } else {
                      shippingAddress.phone = '$selectedCountryCode${phone.text}';
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '${locale.lblCountry} ${locale.lblIsRequired}';
                    }
                    return null;
                  },
                ).expand(flex: 2),

                16.width,

                Expanded(
                  flex: 5,
                  child: AppTextField(
                    enabled: !appStore.isLoading,
                    controller: phone,
                    focus: phoneFocus,
                    nextFocus: widget.isBilling ? emailFocus : null,
                    keyboardType: TextInputType.phone,
                    textInputAction: widget.isBilling ? TextInputAction.next : TextInputAction.done,
                    textFieldType: TextFieldType.PHONE,
                    textStyle: primaryTextStyle(),
                    decoration: inputDecoration(
                      context: context,
                      labelText: locale.lblContactNumber,
                      fillColor: context.scaffoldBackgroundColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '${locale.lblContactNumber} ${locale.lblIsRequired}';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      if (widget.isBilling) {
                        billingAddress.phone = '$selectedCountryCode$text';
                      } else {
                        shippingAddress.phone = '$selectedCountryCode$text';
                      }
                    },
                    onFieldSubmitted: (text) {
                      if (widget.isBilling) {
                        billingAddress.phone = '$selectedCountryCode$text';
                      } else {
                        shippingAddress.phone = '$selectedCountryCode$text';
                      }
                      validateAndSaveForm();
                    },
                  ),
                ),
              ],
            ),
            16.height,
            if (widget.isBilling)
              AppTextField(
                enabled: !appStore.isLoading,
                controller: email,
                focus: emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                textFieldType: TextFieldType.EMAIL,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecoration(
                  context: context,
                  labelText: locale.lblEmail,
                  fillColor: context.scaffoldBackgroundColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${locale.lblEmail} ${locale.lblIsRequired}';
                  }
                  if (!value.isEmail()) {
                    return locale.lblEnterYourEmailAddress;
                  }
                  return null;
                },
                onChanged: (text) {
                  billingAddress.email = text;
                },
                onFieldSubmitted: (text) {
                  billingAddress.email = text;
                  validateAndSaveForm();
                },
              ),
            16.height,
            16.height,
          ],
        ),
      ),
    );
  }
}
