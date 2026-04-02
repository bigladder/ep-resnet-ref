from sys import argv

# import resdx

# print(resdx.__file__)

from koozie import fr_u

from resdx import (
    EnergyPlusSystemType,
    FanMotorType,
    RESNETDXModel,
    StagingType,
    create_idf_string,
    get_select_idf_objects,
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

    objects = get_select_idf_objects(
        unit=unit,
        system_name="HVAC ",
        system_type=EnergyPlusSystemType.UNITARY_SYSTEM,
        autosize=False,
        normalize=False,
        get_independent_variable_lists=True,
        get_cooling_performance_map=True,
        get_heating_performance_map=True,
    )

    object_string = create_idf_string(objects)

    return object_string


# stage_type = "SINGLE_STAGE"
# cooling_capacity_95_W = "38300"
# heating_capacity_47_W = "56100"
# heating_capacity_17_W = "40000"
# minimum_rated_temperature_degC = "-25"
# seer2 = "9.50"
# eer2 = "8.32"
# hspf2 = "5.78"
# motor_type = "PSC"
# duct_type = "DUCTED"

# stage_type = "SINGLE_STAGE"
# cooling_capacity_95_W = "11214.639115548554"
# heating_capacity_47_W = "13644.965607952026"
# heating_capacity_17_W = "8541.748470577968"
# minimum_rated_temperature_degC = "0"
# seer2 = "9.50"
# eer2 = "8.32"
# hspf2 = "5.78"
# motor_type = "PSC"
# duct_type = "DUCTED"


# get_performance_map(
#     stage_type=stage_type,
#     cooling_capacity_95_W=cooling_capacity_95_W,
#     heating_capacity_47_W=heating_capacity_47_W,
#     heating_capacity_17_W=heating_capacity_17_W,
#     minimum_rated_temperature_degC=minimum_rated_temperature_degC,
#     seer2=seer2,
#     eer2=eer2,
#     hspf2=hspf2,
#     motor_type=motor_type,
#     duct_type=duct_type,
# )


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
        )
    )
