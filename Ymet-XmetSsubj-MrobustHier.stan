data {
  int<lower=1> n_subj;
  int<lower=1> n_total;
  vector[n_total] y;
  vector[n_total] x;
  vector<lower=0>[n_total] w;
  int<lower=1> s[n_total];
}
transformed data {
  // Standardize the data:
  vector[n_total] zx;
  vector[n_total] zy;
  vector[n_total] zw;
  real wm;
  real x_m;
  real y_m;
  real x_sd;
  real y_sd;
  x_m = mean(x);
  y_m = mean(y);
  wm = mean(w);
  x_sd = sd(x);
  y_sd = sd(y);
  zx = (x - x_m) / x_sd; 
  zy = (y - y_m) / y_sd; 
  zw = w / wm ;
}
parameters {
  vector[n_subj] z_beta_0;
  vector[n_subj] z_beta_1;
  real<lower=0> z_sigma;
  real z_beta_0_mu; 
  real z_beta_1_mu; 
  real<lower=0> z_beta_0_sigma;
  real<lower=0> z_beta_1_sigma;
  real<lower=0> nu_minus_one;
}
transformed parameters {
  real<lower=0> nu;
  nu = nu_minus_one+1;
} 
model {
  z_beta_0_mu ~ normal(0, 10);
  z_beta_1_mu ~ normal(0, 10);
  z_sigma ~ uniform(1.0E-3, 1.0E+3);
  z_beta_0_sigma ~ uniform(1.0E-3, 1.0E+3);
  z_beta_1_sigma ~ uniform(1.0E-3, 1.0E+3);
  nu_minus_one ~ exponential(1/29.0);
  z_beta_0 ~ normal(z_beta_0_mu, z_beta_0_sigma);
  z_beta_1 ~ normal(z_beta_1_mu, z_beta_1_sigma);
  zy ~ student_t(nu, z_beta_0[s] + z_beta_1[s] .* zx, zw * z_sigma);
}  
generated quantities { 
  vector[n_subj] beta_0;
  vector[n_subj] beta_1;
  real<lower=0> sigma;
  real beta_0_mu; 
  real beta_1_mu; 

  // Transform to original scale:
  beta_1 = z_beta_1 * y_sd / x_sd;
  beta_0 = z_beta_0 * y_sd  + y_m - z_beta_1 * x_m * y_sd / x_sd;
  beta_1_mu = z_beta_1_mu * y_sd / x_sd;
  beta_0_mu = z_beta_0_mu * y_sd  + y_m - z_beta_1_mu * x_m * y_sd / x_sd;
  sigma = z_sigma * y_sd;
}
