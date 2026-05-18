from sys import argv

from koozie import fr_u

from resdx import (
    EnergyPlusSystemType,
    FanMotorType,
    RESNETDXModel,
    StagingType,
    write_idf,
)


def get_performance_map(
    stage_type: str,
    cooling_capacity_95_W: str,
    heating_capacity_47_W: str,
    heating_capacity_17_W: str,
    minimum_rated_temperature_degC: str,
    seer2: str,
    eer2: str,
    hspf2: str,
    motor_type: str,
    duct_type: str,
    heating_type: str,
) -> str:  # type: ignore
    """
    Get IDF objects
    """
    stage_type = StagingType[stage_type]

    cooling_capacity_95 = fr_u(float(cooling_capacity_95_W), "W")
    heating_capacity_47 = fr_u(float(heating_capacity_47_W), "W")
    heating_capacity_17 = fr_u(float(heating_capacity_17_W), "W")

    minimum_rated_temperature = fr_u(float(minimum_rated_temperature_degC), "degC")

    seer2: float = float(seer2)  # type: ignore
    eer2: float = float(eer2)  # type: ignore
    hspf2: float = float(hspf2)  # type: ignore

    motor_type = FanMotorType[motor_type]

    if duct_type == "DUCTED":
        is_ducted = True
    else:  # duct_type == "DUCTLESS"
        is_ducted = False

    if heating_type == "ASHP":
        get_heating_performance_map = True
    else:  # heating_type == "GAS" or heating_type == "ELECTRIC"
        get_heating_performance_map = False

    unit = RESNETDXModel(
        staging_type=stage_type,
        rated_net_total_cooling_capacity=cooling_capacity_95,
        rated_net_heating_capacity=heating_capacity_47,
        rated_net_heating_capacity_17=heating_capacity_17,
        heating_off_temperature=minimum_rated_temperature,
        input_seer=seer2,
        input_eer=eer2,
        input_hspf=hspf2,
        motor_type=motor_type,
        is_ducted=is_ducted,
    )

    objects = write_idf(
        unit=unit,
        heating_type=heating_type,
        system_name="HVAC",
        system_type=EnergyPlusSystemType.UNITARY_SYSTEM,
        autosize=False,
        normalize=False,
        get_fan=True,
        get_independent_variable_lists=True,
        get_cooling_performance_map=True,
        get_heating_performance_map=get_heating_performance_map,
        return_idf_objects=True,
    )

    return objects


if __name__ == "__main__":
    stage_type = argv[1]
    cooling_capacity_95_W = argv[2]
    heating_capacity_47_W = argv[3]
    heating_capacity_17_W = argv[4]
    minimum_rated_temperature_degC = argv[5]
    seer2 = argv[6]
    eer2 = argv[7]
    hspf2 = argv[8]
    motor_type = argv[9]
    duct_type = argv[10]
    heating_type = argv[11]

    print(
        get_performance_map(
            stage_type=stage_type,
            cooling_capacity_95_W=cooling_capacity_95_W,
            heating_capacity_47_W=heating_capacity_47_W,
            heating_capacity_17_W=heating_capacity_17_W,
            minimum_rated_temperature_degC=minimum_rated_temperature_degC,
            seer2=seer2,
            eer2=eer2,
            hspf2=hspf2,
            motor_type=motor_type,
            duct_type=duct_type,
            heating_type=heating_type,
        )
    )
