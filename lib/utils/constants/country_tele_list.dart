import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class CountryCodeUtils {
  static String getFlagFromIsoCode(IsoCode isoCode) {
    final flagMap = {
      IsoCode.AF: '🇦🇫',
      IsoCode.AL: '🇦🇱',
      IsoCode.DZ: '🇩🇿',
      IsoCode.AS: '🇦🇸',
      IsoCode.AD: '🇦🇩',
      IsoCode.AO: '🇦🇴',
      IsoCode.AI: '🇦🇮',
      IsoCode.AG: '🇦🇬',
      IsoCode.AR: '🇦🇷',
      IsoCode.AM: '🇦🇲',
      IsoCode.AW: '🇦🇼',
      IsoCode.AU: '🇦🇺',
      IsoCode.AT: '🇦🇹',
      IsoCode.AZ: '🇦🇿',
      IsoCode.BS: '🇧🇸',
      IsoCode.BH: '🇧🇭',
      IsoCode.BD: '🇧🇩',
      IsoCode.BB: '🇧🇧',
      IsoCode.BY: '🇧🇾',
      IsoCode.BE: '🇧🇪',
      IsoCode.BZ: '🇧🇿',
      IsoCode.BJ: '🇧🇯',
      IsoCode.BM: '🇧🇲',
      IsoCode.BT: '🇧🇹',
      IsoCode.BO: '🇧🇴',
      IsoCode.BA: '🇧🇦',
      IsoCode.BW: '🇧🇼',
      IsoCode.BR: '🇧🇷',
      IsoCode.IO: '🇮🇴',
      IsoCode.BN: '🇧🇳',
      IsoCode.BG: '🇧🇬',
      IsoCode.BF: '🇧🇫',
      IsoCode.BI: '🇧🇮',
      IsoCode.CV: '🇨🇻',
      IsoCode.KH: '🇰🇭',
      IsoCode.CM: '🇨🇲',
      IsoCode.CA: '🇨🇦',
      IsoCode.KY: '🇰🇾',
      IsoCode.CF: '🇨🇫',
      IsoCode.TD: '🇹🇩',
      IsoCode.CL: '🇨🇱',
      IsoCode.CN: '🇨🇳',
      IsoCode.CO: '🇨🇴',
      IsoCode.KM: '🇰🇲',
      IsoCode.CG: '🇨🇬',
      IsoCode.CD: '🇨🇩',
      IsoCode.CK: '🇨🇰',
      IsoCode.CR: '🇨🇷',
      IsoCode.CI: '🇨🇮',
      IsoCode.HR: '🇭🇷',
      IsoCode.CU: '🇨🇺',
      IsoCode.CY: '🇨🇾',
      IsoCode.CZ: '🇨🇿',
      IsoCode.DK: '🇩🇰',
      IsoCode.DJ: '🇩🇯',
      IsoCode.DM: '🇩🇲',
      IsoCode.DO: '🇩🇴',
      IsoCode.EC: '🇪🇨',
      IsoCode.EG: '🇪🇬',
      IsoCode.SV: '🇸🇻',
      IsoCode.GQ: '🇬🇶',
      IsoCode.ER: '🇪🇷',
      IsoCode.EE: '🇪🇪',
      IsoCode.ET: '🇪🇹',
      IsoCode.FJ: '🇫🇯',
      IsoCode.FI: '🇫🇮',
      IsoCode.FR: '🇫🇷',
      IsoCode.GA: '🇬🇦',
      IsoCode.GM: '🇬🇲',
      IsoCode.GE: '🇬🇪',
      IsoCode.DE: '🇩🇪',
      IsoCode.GH: '🇬🇭',
      IsoCode.GR: '🇬🇷',
      IsoCode.GD: '🇬🇩',
      IsoCode.GU: '🇬🇺',
      IsoCode.GT: '🇬🇹',
      IsoCode.GG: '🇬🇬',
      IsoCode.GN: '🇬🇳',
      IsoCode.GW: '🇬🇼',
      IsoCode.GY: '🇬🇾',
      IsoCode.HT: '🇭🇹',
      IsoCode.HN: '🇭🇳',
      IsoCode.HU: '🇭🇺',
      IsoCode.IS: '🇮🇸',
      IsoCode.IN: '🇮🇳',
      IsoCode.ID: '🇮🇩',
      IsoCode.IR: '🇮🇷',
      IsoCode.IQ: '🇮🇶',
      IsoCode.IE: '🇮🇪',
      IsoCode.IM: '🇮🇲',
      IsoCode.IT: '🇮🇹',
      IsoCode.JM: '🇯🇲',
      IsoCode.JP: '🇯🇵',
      IsoCode.JE: '🇯🇪',
      IsoCode.JO: '🇯🇴',
      IsoCode.KZ: '🇰🇿',
      IsoCode.KE: '🇰🇪',
      IsoCode.KI: '🇰🇮',
      IsoCode.KW: '🇰🇼',
      IsoCode.KG: '🇰🇬',
      IsoCode.LA: '🇱🇦',
      IsoCode.LV: '🇱🇻',
      IsoCode.LB: '🇱🇧',
      IsoCode.LS: '🇱🇸',
      IsoCode.LR: '🇱🇷',
      IsoCode.LY: '🇱🇾',
      IsoCode.LI: '🇱🇮',
      IsoCode.LT: '🇱🇹',
      IsoCode.LU: '🇱🇺',
      IsoCode.MG: '🇲🇬',
      IsoCode.MW: '🇲🇼',
      IsoCode.MY: '🇲🇾',
      IsoCode.MV: '🇲🇻',
      IsoCode.ML: '🇲🇱',
      IsoCode.MT: '🇲🇹',
      IsoCode.MH: '🇲🇭',
      IsoCode.MR: '🇲🇷',
      IsoCode.MU: '🇲🇺',
      IsoCode.MX: '🇲🇽',
      IsoCode.FM: '🇫🇲',
      IsoCode.MD: '🇲🇩',
      IsoCode.MC: '🇲🇨',
      IsoCode.MN: '🇲🇳',
      IsoCode.ME: '🇲🇪',
      IsoCode.MA: '🇲🇦',
      IsoCode.MZ: '🇲🇿',
      IsoCode.MM: '🇲🇲',
      IsoCode.NA: '🇳🇦',
      IsoCode.NP: '🇳🇵',
      IsoCode.NL: '🇳🇱',
      IsoCode.NZ: '🇳🇿',
      IsoCode.NI: '🇳🇮',
      IsoCode.NE: '🇳🇪',
      IsoCode.NG: '🇳🇬',
      IsoCode.NU: '🇳🇺',
      IsoCode.KP: '🇰🇵',
      IsoCode.NO: '🇳🇴',
      IsoCode.OM: '🇴🇲',
      IsoCode.PK: '🇵🇰',
      IsoCode.PW: '🇵🇼',
      IsoCode.PA: '🇵🇦',
      IsoCode.PG: '🇵🇬',
      IsoCode.PY: '🇵🇾',
      IsoCode.PE: '🇵🇪',
      IsoCode.PH: '🇵🇭',
      IsoCode.PL: '🇵🇱',
      IsoCode.PT: '🇵🇹',
      IsoCode.QA: '🇶🇦',
      IsoCode.RO: '🇷🇴',
      IsoCode.RU: '🇷🇺',
      IsoCode.RW: '🇷🇼',
      IsoCode.SA: '🇸🇦',
      IsoCode.SN: '🇸🇳',
      IsoCode.RS: '🇷🇸',
      IsoCode.SG: '🇸🇬',
      IsoCode.SK: '🇸🇰',
      IsoCode.SI: '🇸🇮',
      IsoCode.ZA: '🇿🇦',
      IsoCode.ES: '🇪🇸',
      IsoCode.SE: '🇸🇪',
      IsoCode.CH: '🇨🇭',
      IsoCode.TW: '🇹🇼',
      IsoCode.TZ: '🇹🇿',
      IsoCode.TH: '🇹🇭',
      IsoCode.TG: '🇹🇬',
      IsoCode.TO: '🇹🇴',
      IsoCode.TT: '🇹🇹',
      IsoCode.TN: '🇹🇳',
      IsoCode.TR: '🇹🇷',
      IsoCode.UA: '🇺🇦',
      IsoCode.AE: '🇦🇪',
      IsoCode.GB: '🇬🇧',
      IsoCode.UG: '🇺🇬',
      IsoCode.US: '🇺🇸',
      IsoCode.VN: '🇻🇳',
      IsoCode.ZM: '🇿🇲',
      IsoCode.ZW: '🇿🇼',
    };

    return flagMap[isoCode] ?? '🌐';
  }
}
