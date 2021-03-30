// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.modakoda.onlineradiosearchmobile;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.widget.TextView;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory;
import java.util.Map;

public class NativeAdFactoryExample implements NativeAdFactory {
  private final LayoutInflater layoutInflater;

  public NativeAdFactoryExample(LayoutInflater layoutInflater) {
    this.layoutInflater = layoutInflater;
  }

  @Override
  public UnifiedNativeAdView createNativeAd(
      UnifiedNativeAd nativeAd, Map<String, Object> customOptions) {
    final UnifiedNativeAdView adView =
        (UnifiedNativeAdView) layoutInflater.inflate(R.layout.admob_ad, null);
    final TextView headlineView = adView.findViewById(R.id.ad_headline);
    final TextView bodyView = adView.findViewById(R.id.ad_body);

    headlineView.setText(nativeAd.getHeadline());
    bodyView.setText(nativeAd.getBody());

    adView.setBackgroundColor(Color.YELLOW);

    adView.setNativeAd(nativeAd);
    adView.setBodyView(bodyView);
    adView.setHeadlineView(headlineView);
    return adView;
  }
}
