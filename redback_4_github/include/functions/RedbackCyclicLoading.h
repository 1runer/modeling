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

#ifndef REDBACKCYCLICLOADING_H
#define REDBACKCYCLICLOADING_H

#include "Function.h"
#include "Postprocessor.h"
#include "RedbackElementAverageValue.h"

class RedbackCyclicLoading;

template<>
InputParameters validParams<RedbackCyclicLoading>();

/**
 * This is a function for cyclic changes in values for a specified number of cycles. For example the displacement of the upper boundary
 * in a triaxial test with cyclic loading.
 */
class RedbackCyclicLoading : public Function
{
public:
  RedbackCyclicLoading(const InputParameters & parameters);

  virtual Real value(Real t, const Point & p) override;

protected:
  Real _boundary_min;
  Real _boundary_max;
  Real _disp_velocity;
  Real _disp_velocity2;
  Real _delta_b_max;
  Real _cyclicnumber;
  const PostprocessorValue & _value_avg;
  Real _value_avg_n;
  Real _finalfunction;
  Real _tturn;
  Real _disp_absolut1;
  Real _disp_absolut2;
  Real _disp_cyclic;
  int _cycles;
 };
#endif // REDBACKCYCLICLOADING_H
