/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "RedbackElementAverageValue.h"

template <>
InputParameters
validParams<RedbackElementAverageValue>()
{
  InputParameters params = validParams<ElementIntegralVariablePostprocessor>();
//  params.addParam<std::string>("Mises stress","mises","The name of the mises material property that will be used in the function.");
  return params;
}

RedbackElementAverageValue::RedbackElementAverageValue(const InputParameters & parameters)
  : ElementIntegralVariablePostprocessor(parameters),
  _volume(0)
//  _mises_stress(getMaterialProperty<Real>("mises_stress"))
{
}

void
RedbackElementAverageValue::initialize()
{
  ElementIntegralVariablePostprocessor::initialize();
  _volume = 0;
  std::string _object_name = "RedbackElementAverageValue";
}

void
RedbackElementAverageValue::execute()
{
  ElementIntegralVariablePostprocessor::execute();

  _volume += _current_elem_volume;
}

Real
RedbackElementAverageValue::getValue()
{
//  Real integral = ElementIntegralVariablePostprocessor::getValue();

  Real avg_pp = ElementIntegralVariablePostprocessor::getValue();
  gatherSum(_volume);

//  return integral / _volume;
  return value_avg = avg_pp / _volume;
}

void
RedbackElementAverageValue::threadJoin(const UserObject & y)
{
  ElementIntegralVariablePostprocessor::threadJoin(y);
  const RedbackElementAverageValue & pps = static_cast<const RedbackElementAverageValue &>(y);
  _volume += pps._volume;
}
