#[Mesh]
#  type = GeneratedMesh
#  dim = 2
#  nx = 10
#  ny = 10
#  xmin = -1
#  ymin = -1
#[]

[Mesh]
  type = FileMesh
  # file = Mesh_PfSst_7_Fine_6.msh
  file = Mesh_Cylinder_2_1.msh
  # file = Mesh_PfSst_7_Medium_4.msh
  # Mesh with stronger perturbations
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
  [./temp]
  [../]
[]

[RedbackMechAction]
  [./solid]
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    temp = temp
  [../]
[]


[Materials]
  [./mat0]
    type = RedbackMaterial
    block = 0
    disp_y = disp_y
    disp_x = disp_x
  #  C_ijkl = '1.346e+03 5.769e+02 5.769e+02 1.346e+03 5.769e+02 1.346e+03 3.846e+02 3.846e+02 3.846e+2'
    temperature = temp
  # yield_stress = '0. 1 1. 1'
    disp_z = disp_z
  #  ar_c = 1
  #  m = 2
  #  da = 1
  #  mu = 1
    ar = 10 # 14 # 5
    gr = 1 # 5 # 10
    pore_pres = 0
    ref_lewis_nb = 1
  #  is_mechanics_on = true
  [../]
  [./mat0_mech]
    type = RedbackMechMaterialJ2
    block = 0
    disp_y = disp_y
    disp_x = disp_x
  #  C_ijkl = '1.346e+03 5.769e+02 5.769e+02 1.346e+03 5.769e+02 1.346e+03 3.846e+02 3.846e+02 3.846e+2'
    temperature = temp
#    yield_stress = '0. 1 1. 1'
    yield_stress = '0. 0.01 1. 0.01 2. 0.01'
    disp_z = disp_z
    pore_pres = 0
    youngs_modulus = 80 # own value for working
    poisson_ratio = 0.4 # own value for working
  [../]
[]

[Functions]
  active = 'spline_IC downfunc'
  [./downfunc]
    type = ParsedFunction
    value = -0.1*t
  [../]
  [./spline_IC]
    type = ConstantFunction
    value = 1
  [../]
[]

[BCs]
  [./disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'bottom top'
    value = 0
  [../]
  [./disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom top'
    value = 0
  [../]
  [./top_disp_z]
    type = FunctionPresetBC
    variable = disp_z
    boundary = top
    function = downfunc
  [../]
  [./bottom_disp_z]
    type = DirichletBC
    variable = disp_z
    boundary = bottom
    value = 0
  [../]
[]

[AuxVariables]
  active = 'Mod_Gruntfest_number mises_strain mech_diss mises_strain_rate mises_stress'
  [./stress_zz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./peeq]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./pe11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./pe22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./pe33]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./mises_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./mises_strain]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./mises_strain_rate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./mech_diss]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Mod_Gruntfest_number]
    order = CONSTANT
    family = MONOMIAL
    block = '0'
  [../]
[]

[Kernels]
  active = 'temp_dissip temp_diff temp_td'
  [./temp_td]
    type = TimeDerivative
    variable = temp
    block = 0
  [../]
  [./temp_diff]
    type = Diffusion
    variable = temp
    block = 0
  [../]
  [./temp_Andiff]
    type = AnisotropicDiffusion
    variable = temp
    block = 0
    tensor_coeff = '1 0 0 0 1 0 0 0 1'
  [../]
  [./temp_dissip]
    type = RedbackMechDissip
    variable = temp
    block = 0
  [../]
[]

[AuxKernels]
  active = 'mises_strain mises_strain_rate mises_stress mech_dissipation Gruntfest_Number'
  [./stress_zz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zz
    index_i = 2
    index_j = 2
  [../]
  [./pe11]
    type = RankTwoAux
    rank_two_tensor = plastic_strain
    variable = pe11
    index_i = 0
    index_j = 0
  [../]
  [./pe22]
    type = RankTwoAux
    rank_two_tensor = plastic_strain
    variable = pe22
    index_i = 1
    index_j = 1
  [../]
  [./pe33]
    type = RankTwoAux
    rank_two_tensor = plastic_strain
    variable = pe33
    index_i = 2
    index_j = 2
  [../]
  [./eqv_plastic_strain]
    type = FiniteStrainPlasticAux
    variable = peeq
  [../]
  [./mises_stress]
    type = MaterialRealAux
    variable = mises_stress
    property = mises_stress
  [../]
  [./mises_strain]
    type = MaterialRealAux
    variable = mises_strain
    property = mises_strain
  [../]
  [./mises_strain_rate]
    type = MaterialRealAux
    variable = mises_strain_rate
    property = mises_strain_rate
  [../]
  [./mech_dissipation]
    type = MaterialRealAux
    variable = mech_diss
    property = mechanical_dissipation_mech
  [../]
  [./Gruntfest_Number]
    type = MaterialRealAux
    variable = Mod_Gruntfest_number
    property = mod_gruntfest_number
  [../]
[]

[Postprocessors]
  active = 'temp_centre mises_strain strain_rate mises_stress Gruntfest_number'
  [./temp_centre]
    type = PointValue
    variable = temp
    point = '0 0 1'
  [../]
  [./strain_rate]
    type = PointValue
    variable = mises_strain_rate
    point = '0 0 1'
  [../]
  [./mises_stress]
    type = PointValue
    variable = mises_stress
    point = '0 0 1'
  [../]
  [./Gruntfest_number]
    type = PointValue
    variable = Mod_Gruntfest_number
    point = '0 0 1'
  [../]
  [./mises_strain]
    type = PointValue
    variable = mises_strain
    point = '0 0 1'
  [../]
[]

[Preconditioning]
  # active = ''
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  start_time = 0.0
  end_time = 1
  dtmax = 1
  dtmin = 1e-7
  type = Transient
  l_max_its = 50
  nl_max_its = 10
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -snes_linesearch_type -ksp_gmres_restart'
  petsc_options_value = 'hypre boomeramg cp 201'
  nl_abs_tol = 1e-6 # 1e-10 to begin with
  reset_dt = true
  line_search = basic
  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 1e-3
  [../]
[]

[Outputs]
  file_base = out_3_7
  output_initial = true
  exodus = true
  [./console]
    type = Console
    perf_log = true
    output_linear = true
  [../]
[]

[ICs]
  active = 'ic_temp'
  [./ic_temp]
    variable = temp
    value = 0
    type = ConstantIC
    block = '0'
  [../]
[]
