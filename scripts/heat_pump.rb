def calc_EIR_from_EER(eer, fan_power_rated)
    return ((1.0 - (fan_power_rated * 0.03333) * 3.412) / eer - fan_power_rated * 0.03333) * 3.412
end

def calc_EIR_from_COP(cop, fan_power_rated)
    return ((1.0/3.412 + fan_power_rated * 0.03333) / cop - fan_power_rated * 0.03333) * 3.412
end

def calc_EER_from_EIR(eir, fan_power_rated)
    cfm_per_btuh = 400.0 / 12000.0
    return ((1.0 - 3.412 * (fan_power_rated * cfm_per_btuh)) / (eir / 3.412 + (fan_power_rated * cfm_per_btuh)))
end

def calc_biquad(coeff, in_1, in_2)
    return coeff[0] + coeff[1] * in_1 + coeff[2] * in_1 * in_1 + coeff[3] * in_2 + coeff[4] * in_2 * in_2 + coeff[5] * in_1 * in_2
end

def calc_EIR_cooling_1spd(seer, fan_power_rated, c_d, coeff_eir)
    eer = calc_EER_cooling_1spd(seer, fan_power_rated, c_d, coeff_eir)
    return calc_EIR_from_EER(eer, fan_power_rated)
end

def calc_EIR_heating_1spd(hspf, fan_power_rated, c_d, coeff_eir, coeff_q)
    cop = calc_COP_heating_1spd(hspf, fan_power_rated, c_d, coeff_eir, coeff_q)
    return calc_EIR_from_COP(cop, fan_power_rated)
end

def calc_EER_cooling_1spd(seer, fan_power_rated, c_d, coeff_eir)
    # Directly calculate cooling coil net EER at condition A (95/80/67) using SEER

    # 1. Calculate eer_b using SEER and c_d
    eer_b = seer / (1.0 - 0.5 * c_d)

    # 2. Calculate eir_b
    eir_b = calc_EIR_from_EER(eer_b, fan_power_rated)

    # 3. Calculate eir_a using performance curves
    eir_a = eir_b / calc_biquad(coeff_eir, 67.0, 82.0)
    eer_a = calc_EER_from_EIR(eir_a, fan_power_rated)

    return eer_a
end

def calc_COP_heating_1spd(hspf, fan_power_rated, c_d, coeff_eir, coeff_q)
    # Iterate to find rated net COP given HSPF using simple bisection method

    # Initial large bracket to span possible HSPF range
    cop_a = 0.1
    cop_b = 10.0

    # Iterate
    tol = 0.0001

    err = 1.0
    cop_c = (cop_a + cop_b) / 2.0
    for n in 0..99
      f_a = calc_HSPF_1spd(cop_a, fan_power_rated, c_d, coeff_eir, coeff_q) - hspf
      f_c = calc_HSPF_1spd(cop_c, fan_power_rated, c_d, coeff_eir, coeff_q) - hspf

      if f_c == 0
        return cop_c
      elsif f_a * f_c < 0
        cop_b = cop_c
      else
        cop_a = cop_c
      end

      cop_c = (cop_a + cop_b) / 2.0
      err = (cop_b - cop_a) / 2.0

      if err <= tol
        break
      end
    end

    if err > tol
      cop_c = -99
    end

    return cop_c
end

def calc_HSPF_1spd(cop_47, fan_power_rated, c_d, coeff_eir, coeff_q)
    # Single speed HSPF calculation
    cfm_per_btuh = 400.0 / 12000.0
    eir_47 = calc_EIR_from_COP(cop_47, fan_power_rated)
    eir_35 = eir_47 * calc_biquad(coeff_eir, 70.0, 35.0)
    eir_17 = eir_47 * calc_biquad(coeff_eir, 70.0, 17.0)

    q_47 = 1.0
    q_35 = 0.7519
    q_17 = q_47 * calc_biquad(coeff_q, 70.0, 17.0)

    q_47_net = q_47 + fan_power_rated * 3.412 * cfm_per_btuh
    q_35_net = q_35 + fan_power_rated * 3.412 * cfm_per_btuh
    q_17_net = q_17 + fan_power_rated * 3.412 * cfm_per_btuh

    p_47 = (q_47 * eir_47) / 3.412 + fan_power_rated * cfm_per_btuh
    p_35 = (q_35 * eir_35) / 3.412 + fan_power_rated * cfm_per_btuh
    p_17 = (q_17 * eir_17) / 3.412 + fan_power_rated * cfm_per_btuh

    t_bins = [62.0, 57.0, 52.0, 47.0, 42.0, 37.0, 32.0, 27.0, 22.0, 17.0, 12.0, 7.0, 2.0, -3.0, -8.0]
    frac_hours = [0.132, 0.111, 0.103, 0.093, 0.100, 0.109, 0.126, 0.087, 0.055, 0.036, 0.026, 0.013, 0.006, 0.002, 0.001]

    designtemp = 5.0
    t_off = 10.0
    t_on = 14.0
    ptot = 0.0
    rHtot = 0.0
    bLtot = 0.0
    dHRmin = q_47
    for i in 0..14
      bL = ((65.0 - t_bins[i]) / (65.0 - designtemp)) * 0.77 * dHRmin

      if t_bins[i] > 17.0 and t_bins[i] < 45.0
        q_h = q_17_net + (((q_35_net - q_17_net) * (t_bins[i] - 17.0)) / (35.0 - 17.0))
        p_h = p_17 + (((p_35 - p_17) * (t_bins[i] - 17.0)) / (35.0 - 17.0))
      else
        q_h = q_17_net + (((q_47_net - q_17_net) * (t_bins[i] - 17.0)) / (47.0 - 17.0))
        p_h = p_17 + (((p_47 - p_17) * (t_bins[i] - 17.0)) / (47.0 - 17.0))
      end

      x_t = [bL / q_h, 1.0].min

      pLF = 1.0 - (c_d * (1.0 - x_t))
      if t_bins[i] <= t_off or q_h / (3.412 * p_h) < 1.0
        sigma_t = 0.0
      elsif t_off < t_bins[i] and t_bins[i] <= t_on and q_h / (p_h * 3.412) >= 1.0
        sigma_t = 0.5
      elsif t_bins[i] > t_on and q_h / (3.412 * p_h) >= 1.0
        sigma_t = 1.0
      end

      p_h_i = (x_t * p_h * sigma_t / pLF) * frac_hours[i]
      rH_i = ((bL - (x_t * q_h * sigma_t)) / 3.412) * frac_hours[i]
      bL_i = bL * frac_hours[i]
      ptot += p_h_i
      rHtot += rH_i
      bLtot += bL_i
    end

    hspf = bLtot / (ptot + rHtot)
    return hspf
end


def calc_heat_pump_COPs(seer, hspf)
    if seer <= 15
        fan_power_rated = 0.365 # W/cfm
    else
        fan_power_rated = 0.14 # W/cfm
    end

    if seer < 13
        c_d_cooling = 0.20
    else
        c_d_cooling = 0.07
    end

    if hspf < 7
        c_d_heating = 0.20
    else
        c_d_heating = 0.11
    end

    # Table 13. HP EIR Coefficients as a Function of Operating Temperatures (deg-F)
    coeff_eir_cooling = [-3.437356399, 0.136656369, -0.001049231, -0.0079378, 0.000185435, -0.0001441]
    coeff_eir_heating = [0.718398423, 0.003498178, 0.000142202, -0.005724331, 0.00014085, -0.000215321]

    # Table 12. HP Total Capacity Coefficients as a Function of Operating Temperatures (deg-F)
    coeff_q_heating = [0.566333415, -0.000744164, -0.0000103, 0.009414634, 0.0000506, -0.00000675]

    cop_cooling = 1.0 / calc_EIR_cooling_1spd(seer, fan_power_rated, c_d_cooling, coeff_eir_cooling)
    cop_heating = 1.0 / calc_EIR_heating_1spd(hspf, fan_power_rated, c_d_heating, coeff_eir_heating, coeff_q_heating)

    return cop_cooling, cop_heating, c_d_cooling, c_d_heating
end
