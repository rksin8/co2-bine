# Problem discription
# Domain: 200m x 6 mhttps://github.com/rksin8/co2-bine/blob/main/co2_brine_theis.i
# initial pressure: 5e6 Pa
# initial xnacl: 0.1
# left face: CO2 injection
# right face: pressure 1e6
# Top and Bottom: No flow boundary
# Capillary pressure: Brooks-Corey: lambda = 2; entry pressure: 1e4 Pa
# Relative permeability:Brooks-Corey: swr = 0.35 (Swetting), snr = 0.05
# porosity: 0.26
# Permeabiltiy: 1e-13

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 200
  ny = 20
  xmin = 0
  xmax = 200
  ymin = -1506
  ymax = -1500
  bias_x = 1.02
[]

[GlobalParams]
  PorousFlowDictator = 'dictator'
  gravity = '0 -9.81 0'
[]

[AuxVariables]
  [saturation_gas]
    order = CONSTANT
    family = MONOMIAL
  []
  [x1]
    order = CONSTANT
    family = MONOMIAL
  []
  [y0]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [saturation_gas]
    type = PorousFlowPropertyAux
    variable = saturation_gas
    property = saturation
    phase = 1
    execute_on = 'timestep_end'
  []
  [x1]
    type = PorousFlowPropertyAux
    variable = x1
    property = mass_fraction
    phase = 0
    fluid_component = 1
    execute_on = 'timestep_end'
  []
  [y0]
    type = PorousFlowPropertyAux
    variable = y0
    property = mass_fraction
    phase = 1
    fluid_component = 0
    execute_on = 'timestep_end'
  []
[]

[Variables]
  [pgas]
    initial_condition = 5e6
  []
  [zi]
    initial_condition = 0
  []
  [xnacl]
    initial_condition = 0.1
  []
[]

[Kernels]
  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = pgas
  []
  [flux0]
    type = PorousFlowAdvectiveFlux
    fluid_component = 0
    variable = pgas
    gravity = '0 -9.81 0'
  []
  [mass1]
    type = PorousFlowMassTimeDerivative
    fluid_component = 1
    variable = zi
  []
  [flux1]
    type = PorousFlowAdvectiveFlux
    fluid_component = 1
    variable = zi
    gravity = '0 9.81 0'
  []
  [mass2]
    type = PorousFlowMassTimeDerivative
    fluid_component = 2
    variable = xnacl
  []
  [flux2]
    type = PorousFlowAdvectiveFlux
    fluid_component = 2
    variable = xnacl
    gravity = '0 -9.81 0'
    []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pgas zi xnacl'
    number_fluid_phases = 2
    number_fluid_components = 3
  []
  [pc]
    # type = PorousFlowCapillaryPressureBC
    # lambda = 2.0
    # pe = 1e4
    type = PorousFlowCapillaryPressureConst
    pc = 0
  []
  [fs]
    type = PorousFlowBrineCO2
    brine_fp = brine
    co2_fp = co2
    capillary_pressure = pc
  []
[]

[Modules]
  [FluidProperties]
    [co2sw]
      type = CO2FluidProperties
    []
    [co2]
      type = TabulatedFluidProperties
      fp = co2sw
    []
    [water]
      type = Water97FluidProperties
    []
    [watertab]
      type = TabulatedFluidProperties
      fp = water
      temperature_min = 273.15
      temperature_max = 573.15
      pressure_min = 1e5
      pressure_max = 3e7
      fluid_property_file = water_fluid_properties.csv
      save_file = false
    []
    [brine]
      type = BrineFluidProperties
      water_fp = watertab
    []
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
    temperature = '45'
  []
  [brineco2]
    type = PorousFlowFluidState
    gas_porepressure = 'pgas'
    z = 'zi'
    temperature_unit = Celsius
    xnacl = 'xnacl'
    capillary_pressure = pc
    fluid_state = fs
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = '0.26'
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1e-13 0 0 0 1e-13 0 0 0 1e-13'
  []
  [relperm_water]
    type = PorousFlowRelativePermeabilityBC
    lambda = 2.0
    phase = 0
    s_res = 0.35
    sum_s_res = 0.4
    nw_phase = false
  []
  [relperm_gas]
    type = PorousFlowRelativePermeabilityBC
    lambda = 2.0
    nw_phase = true
    phase = 1
    s_res = 0.05
    sum_s_res = 0.4
  []
[]

[BCs]
  [injection]
    type = PorousFlowSink
    variable = zi
    flux_function = -3e-3
    boundary = 'left'
  []
  [right]
    type = FunctionDirichletBC
    variable = pgas
    function = p0
    boundary = 'right'
  []
  [right_xnacl]
    type = PorousFlowOutflowBC
    variable = xnacl
    boundary = 'right'
  []
  [right_zi]
    type = DirichletBC
    variable = zi
    boundary = 'right'
    value = 0
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type'
    petsc_options_value = 'gmres bjacobi lu NONZERO'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 3456000
  nl_max_its = 25
  l_max_its = 10
  dtmax = 1800
  l_abs_tol = 1e-8
  nl_abs_tol = 1e-6
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
  []
  dtmin = 1
[]

[Outputs]
  exodus = true
[]

[Functions]
  [p0]
    type = ParsedFunction
    value = '5.0e6' #
    #value = '5.0e6 - 1173 * 9.81 * y' # -ve y
  []
[]
