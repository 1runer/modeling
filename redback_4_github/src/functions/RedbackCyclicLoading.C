/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/*     REDBACK - Rock mEchanics with Dissipative feedBACKs      */
/*                                                              */
/*              (c) 2014 CSIRO and UNSW Australia               */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*            Prepared by CSIRO and UNSW Australia              */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "RedbackCyclicLoading.h"

template<>
InputParameters validParams<RedbackCyclicLoading>()
{
  InputParameters params = validParams<Function>();
  params.addParam<Real>("boundary_min", 0, "Lower boundary of the cyclic value, e.g. von-Mises stress [Pa].");
  params.addParam<Real>("boundary_max", 1.0, "Upper boundary of the cyclic value, e.g. von-Mises stress [Pa].");
  params.addRequiredParam<Real>("disp_velocity", "The velocity of the constant displacement [m/s].");
  params.addParam<Real>("disp_velocity2", 0.0, "Second velocity for constant displacement [m/s], if there is no value, the inverted disp_velocity is used.");
  params.addParam<Real>("delta_b_max", 0.0, "Constant increase in maximum boundary value, if there is no value, the boundary remains cosntant");
  params.addParam<Real>("cyclicnumber", 1, "The absolut number of cycles before the full displacement will be applied.");
//  params.addParam<PostprocessorName>("RedbackElementAverageValue","RedbackElementAverageValue", "The Postprocessor");
  params.addParam<PostprocessorName>("postprocessor_name","RedbackElementAverageValue", "The Postprocessor");
  params.addClassDescription("Function for cyclic displacement depending on a desired value and lower/upper boundaries.");
  return params;
}

/**
 * This is a function for cyclic changes in values for a specified number of cycles. For example the displacement of the upper boundary
 * in a triaxial test with cyclic loading.
 */

RedbackCyclicLoading::RedbackCyclicLoading(const InputParameters & parameters)
  : Function(parameters),
  _boundary_min(getParam<Real>("boundary_min")),
  _boundary_max(getParam<Real>("boundary_max")),
  _disp_velocity(getParam<Real>("disp_velocity")),
  _disp_velocity2(getParam<Real>("disp_velocity2")),
  _delta_b_max(getParam<Real>("delta_b_max")),
  _cyclicnumber(getParam<Real>("cyclicnumber")),
  _value_avg(getPostprocessorValue("postprocessor_name")),
  _value_avg_n(0),
  _finalfunction(0),
  _tturn(0),
  _disp_absolut1(0),
  _disp_absolut2(0),
  _disp_cyclic(0),
  _cycles(0)
{
}

Real
RedbackCyclicLoading::value(Real t, const Point & p)
{
    if (_disp_velocity2 == 0)
    {
      _disp_velocity2 = (-_disp_velocity);
    }
    if (_value_avg < 0)
    {
      _value_avg_n = (_value_avg) * (-1);
    }
    else
    {
      _value_avg_n = (_value_avg);
    }
    if (_value_avg_n <= _boundary_max && _cycles == 0)
    {
      _disp_absolut1 = _disp_velocity * t;
      _finalfunction = _disp_absolut1;
    }
    else if (_value_avg_n >= _boundary_max && _cycles % 2 == 0 && _cycles <= (2 * _cyclicnumber))
    {
      _cycles = _cycles + 1;
      _tturn = t;
    }
    else if (_value_avg_n >= _boundary_min && _cycles % 2 != 0 && _cycles <= (2 * _cyclicnumber))
    {
      _disp_cyclic = _disp_absolut1;
      _disp_absolut2 = _disp_cyclic + _disp_velocity2 * (t - _tturn);
      _finalfunction = _disp_absolut2;
    }
    else if (_value_avg_n <= _boundary_min && _cycles % 2 != 0 && _cycles <= (2 * _cyclicnumber))
    {
      _cycles = _cycles + 1;
      _tturn = t;
      _boundary_max = _boundary_max + _delta_b_max;
    }
    else if (_value_avg_n <= _boundary_max && _cycles % 2 == 0 && _cycles <= (2 * _cyclicnumber))
    {
      _disp_cyclic = _disp_absolut2;
      _disp_absolut1 = _disp_cyclic + _disp_velocity * (t - _tturn);
      _finalfunction = _disp_absolut1;
    }
    else if (_value_avg_n >= _boundary_max && _cycles == (2 * _cyclicnumber + 1))
    {
      _tturn = t;
      _cycles = _cycles + 1;
    //  _boundary_max = _boundary_max + _delta_b_max;
    }
    // else if (_value_avg_n >= _boundary_max && _cycles > (2 * _cyclicnumber + 1))
    // {
    //   _disp_cyclic = _disp_absolut1;
    //   _finalfunction = _disp_cyclic + _disp_velocity * (t - _tturn);
    //  }
     else
     {
       _disp_cyclic = _disp_absolut1;
       _finalfunction = _disp_cyclic + _disp_velocity * (t - _tturn);
      }
    return _finalfunction;
}
