import 'package:flutter/material.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/image_strings.dart';
import 'package:lul/utils/constants/sizes.dart';

class LFooter extends StatelessWidget {
  const LFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ///Google
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: TColors.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
              onPressed: () {},
              icon: const Image(
                  width: TSizes.iconMd,
                  height: TSizes.iconMd,
                  image: AssetImage(TImages.google))),
        ),

        const SizedBox(
          height: TSizes.spaceBtwItems,
          width: 30,
        ),

        /// Facebook

        Container(
          decoration: BoxDecoration(
              border: Border.all(color: TColors.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
              onPressed: () {},
              icon: const Image(
                  width: TSizes.iconMd,
                  height: TSizes.iconMd,
                  image: AssetImage(TImages.facebook))),
        ),
      ],
    );
  }
}
