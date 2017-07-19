[Mesh]
  type = FileMesh
  file = Mesh_PfSst_1_Coarse.msh
  boundary_name = 'mantle bottom top point_bot'
  block_name = cylinder
  boundary_id = '1 2 3 4'
  block_id = 0
[]

[Variables]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_z]
    order = FIRST
    family = LAGRANGE
  [../]
  [./temperature]
  [../]
  [./pore_pressure]
  [../]
[]

[Materials]
  active = 'Pfinztaeler_Sst_NoMech Pfinztaeler_Sst_Mech_DP'
  [./Pfinztaeler_Sst_NoMech]
    type = RedbackMaterial
    block = cylinder
    disp_z = disp_z
    disp_y = disp_y
    disp_x = disp_x
    total_porosity = total_porosity
    temperature = temperature
    pore_pres = pore_pressure
    solid_density = 2360
    phi0 = 0.2 # from triax
    gr = 8e-4 # exp(-Ar) = 3.3546e-4
    ar = 8 # lit value
    delta = 7.1e-3 # 6.1e-3 # No value = crash
    is_mechanics_on = true
    solid_compressibility = 1 # without not running, with smaller values no plasticity
    alpha_1 = 4.5 # 5 # Lit 4.95
    alpha_2 = 0.5 # Lit 0.85 # need Pore_pressure--> small influence on results
    pressurization_coefficient = 1e-7  # Standard = 0, but without not running
    use_displaced_mesh = false
  [../]
  [./Pfinztaeler_Sst_Mech_DP]
    type = RedbackMechMaterialDP
    block = cylinder
    disp_z = disp_z
    disp_y = disp_y
    disp_x = disp_x
    total_porosity = total_porosity
    temperature = temperature
    pore_pres = pore_pressure
    poisson_ratio = 0.14 # from triax
    youngs_modulus = 1.86e10 # Pa, from triax
    yield_stress = '0 1.12e8 1 1.12e8 2 1.12e8' # empirical from triax
    slope_yield_surface = 0
    exponent = 3 #
    use_displaced_mesh = false
  [../]
[]

[BCs]
  active = 'Dirichlet_Disp_Top Dirichlet_Disp_Bottom Fixed_pt_y Fixed_pt_x Pressure Dirichlet_Temperature'
  [./Dirichlet_Disp_Top]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = top
    function = disp_top_cyclic
  [../]
  [./Dirichlet_Disp_Bottom]
    type = DirichletBC
    variable = disp_z
    boundary = bottom
    value = 0
  [../]
  [./Fixed_pt_x]
    type = PresetBC
    variable = disp_x
    value = 0
    boundary = point_bot
  [../]
  [./Fixed_pt_y]
    type = PresetBC
    variable = disp_y
    value = 0
    boundary = point_bot
  [../]
  [./Dirichlet_Temperature]
    type = DirichletBC
    variable = temperature
    boundary = 'mantle top bottom'
    value = 293.15
  [../]
  [./Pressure]
    [./confinement]
      function = confinement
      disp_z = disp_z
      disp_y = disp_y
      disp_x = disp_x
      boundary = mantle
    [../]
  [../]
[]

[AuxVariables]
  active = 'total_porosity mech_porosity returnmap_iter mises_stress stress_zz elastic_strain plastic_strain total_strain mech_dissip Mod_Gruntfest_number'
  [./total_porosity]
    order = FIRST
    family = MONOMIAL
  [../]
  [./mech_porosity]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./returnmap_iter]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_zz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./mises_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./elastic_strain]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./plastic_strain]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./total_strain]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./mech_dissip]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Mod_Gruntfest_number]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Functions]
  active = 'disp_top_cyclic confinement'
  [./disp_top_cyclic]
    type = RedbackCyclicLoading
    disp_velocity = '-1.122e-5'
    boundary_min = '9e7'
    boundary_max = '1.33e8'
    delta_b_max = '8e6'
    cyclicnumber = 4
  [../]
  [./disp_top]
    type = ParsedFunction
    value = -((1.122e-5)*t)
  [../]
  [./confinement]
    type = ParsedFunction
    value = 2e7
  [../]
[]

[Kernels]
  [./Disp_z]
    type = RedbackStressDivergenceTensors
    variable = disp_z
    disp_z = disp_z
    disp_y = disp_y
    disp_x = disp_x
    component = 2
    block = cylinder
    use_displaced_mesh = true
  [../]
  [./Disp_x]
    type = RedbackStressDivergenceTensors
    variable = disp_x
    disp_z = disp_z
    disp_y = disp_y
    disp_x = disp_x
    component = 0
    block = cylinder
    use_displaced_mesh = true
  [../]
  [./Disp_y]
    type = RedbackStressDivergenceTensors
    variable = disp_y
    disp_z = disp_z
    disp_y = disp_y
    disp_x = disp_x
    component = 1
    block = cylinder
    use_displaced_mesh = true
  [../]
  [./td_Temp]
    type = TimeDerivative
    variable = temperature
  [../]
  [./Thermal_Diff]
    type = RedbackThermalDiffusion
    variable = temperature
  [../]
  [./Mech_Dissip]
    type = RedbackMechDissip
    variable = temperature
  [../]
  [./td_Press]
    type = TimeDerivative
    variable = pore_pressure
  [../]
  [./Press_Diff]
    type = RedbackMassDiffusion
    variable = pore_pressure
  [../]
  [./Thermal_Press]
    type = RedbackThermalPressurization
    variable = pore_pressure
    temperature = temperature
  [../]
  [./PoroMech]
    type = RedbackPoromechanics
    variable = pore_pressure
  [../]
[]

[AuxKernels]
  active = 'total_porosity mech_porosity returnmap_iter mises_stress stress_zz elastic_strain_z plastic_strain_z total_strain_z mech_dissip Gruntfest_Number'
  [./total_porosity]
    type = RedbackTotalPorosityAux
    variable = total_porosity
    mechanical_porosity = mech_porosity
  [../]
  [./mech_porosity]
    type = MaterialRealAux
    variable = mech_porosity
    property = mechanical_porosity
    execute_on = timestep_end
  [../]
  [./returnmap_iter]
    type = MaterialRealAux
    variable = returnmap_iter
    property = returnmap_iter
  [../]
  [./mises_stress]
    type = MaterialRealAux
    variable = mises_stress
    property = mises_stress
  [../]
  [./stress_zz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zz
    index_i = 2
    index_j = 2
  [../]
  [./stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
  [../]
  [./elastic_strain_z]
    type = RankTwoAux
    rank_two_tensor = elastic_strain
    index_i = 2
    index_j = 2
    variable = elastic_strain
  [../]
  [./plastic_strain_z]
    type = RankTwoAux
    rank_two_tensor = plastic_strain
    index_i = 2
    index_j = 2
    variable = plastic_strain
  [../]
  [./total_strain_z]
    type = RankTwoAux
    rank_two_tensor = total_strain
    index_i = 2
    index_j = 2
    variable = total_strain
  [../]
  [./mech_dissip]
    type = MaterialRealAux
    variable = mech_dissip
    property = mechanical_dissipation_mech
  [../]
  [./Gruntfest_Number]
    type = MaterialRealAux
    variable = Mod_Gruntfest_number
    property = mod_gruntfest_number
  [../]
[]

[Postprocessors]
  active = 'max_returnmap_iter elastic_strain_z plastic_strain_z total_strain_z mises_stress temperature_avg Mech_dissip_avg Mod_Gruntfest_avg temperature_core Mech_dissip_core Mod_Gruntfest_core RedbackElementAverageValue'
  [./max_returnmap_iter]
    type = ElementExtremeValue
    variable = returnmap_iter
  [../]
  [./stress_zz]
    type = ElementAverageValue
    variable = stress_zz
  [../]
  [./stress_xx]
    type = ElementAverageValue
    variable = stress_xx
  [../]
  [./elastic_strain_z]
    type = ElementAverageValue
    variable = elastic_strain
  [../]
  [./plastic_strain_z]
    type = ElementAverageValue
    variable = plastic_strain
  [../]
  [./total_strain_z]
    type = ElementAverageValue
    variable = total_strain
  [../]
  [./mises_stress]
    type = ElementAverageValue
    variable = mises_stress
  [../]
  [./temperature_avg]
    type = ElementAverageValue
    variable = temperature
  [../]
  [./Mech_dissip_avg]
    type = ElementAverageValue
    variable = mech_dissip
  [../]
  [./Mod_Gruntfest_avg]
    type = ElementAverageValue
    variable = Mod_Gruntfest_number
  [../]
  [./temperature_core]
    type = PointValue
    variable = temperature
    point = '0 0 0.055'
  [../]
  [./Mech_dissip_core]
    type = PointValue
    variable = mech_dissip
    point = '0 0 0.055'
  [../]
  [./Mod_Gruntfest_core]
    type = PointValue
    variable = Mod_Gruntfest_number
    point = '0 0 0.055'
  [../]
  [./RedbackElementAverageValue]
    type = RedbackElementAverageValue
    variable = stress_zz
  [../]
[]

[Preconditioning]
  [./SMP]
    petsc_options = '-snes_monitor -snes_linesearch_monitor'
    petsc_options_iname = '-ksp_type -pc_type -pc_hypre_type -snes_atol -snes_rtol'
    petsc_options_value = 'gmres     hypre    boomeramg       1E-5       1E-8'
    type = SMP
    full = true
  [../]
[]

[Executioner]
  start_time = 0.0
  end_time = 600
  type = Transient
  l_max_its = 100
  nl_max_its = 10
  solve_type = PJFNK
  line_search = basic
  [./TimeStepper]
    type = ReturnMapIterDT
    min_iter = 10
    ratio = 0.5
    max_iter = 100
    dt_max = 0.5
    postprocessor = max_returnmap_iter
    dt = 1e-3
    dt_min = 1e-9
  [../]
[]

[Outputs]
  csv = true
  file_base = Triax31
  [./console]
    output_linear = true
    type = Console
    output_nonlinear = true
  [../]
    [./exodus_output]
    scalar_as_nodal = true
    file_base = Triax31
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[RedbackMechAction]
  [./solid]
    disp_y = disp_y
    disp_x = disp_x
    disp_z = disp_z
    temp = temperature
    pore_pres = pore_pressure
  [../]
[]

[ICs]
  [./temperature_IC]
    type = ConstantIC
    variable = temperature
    value = 293.15
  [../]
  [./press_ic]
    variable = pore_pressure
    type = ConstantIC
    value = 0
  [../]
[]
