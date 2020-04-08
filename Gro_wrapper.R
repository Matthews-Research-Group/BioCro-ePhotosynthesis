library(BioCro)
# library(ggplot2)
# library(reshape2)

Gro_wrapper <- function(initial_state, parameters, varying_parameters, steady_state_module_names, derivative_module_names){

  result <- Gro_solver(initial_state, parameters, varying_parameters, steady_state_module_names, derivative_module_names)

  # col.palette.muted <- c("#332288", "#117733", "#999933", "#882255")
  # size.title <- 24
  # size.axislabel <-18
  # size.axis <- 18
  # size.legend <- 18
  # 
  # r <- melt(result[,c("doy_dbl","Root","Leaf","Stem","Grain")],id.vars="doy_dbl")
  # 
  # year <- result$year[1]
  # f <- ggplot() + theme_classic()
  # f <- f + geom_point(data=r, aes(x=doy_dbl,y=value, colour=variable))
  # f <- f + labs(title=bquote(.(year)~Ambient~CO[2]), x=paste0('Day of Year (',year,')'),y='Biomass (Mg / ha)')
  # f <- f + scale_x_continuous(breaks = seq(150,275,30))
  # f <- f + theme(plot.title=element_text(size=size.title, hjust=0.5),axis.text=element_text(size=size.axis), axis.title=element_text(size=size.axislabel),legend.position = c(.15,.85), legend.title = element_blank(), legend.text=element_text(size=size.legend))
  # f <- f + guides(colour = guide_legend(override.aes = list(size=3)))
  # f <- f + scale_fill_manual(values = col.palette.muted[2:4])
  # f <- f + scale_colour_manual(values = col.palette.muted, labels=c('Root','Leaf','Stem','Pod'))
  # print(f)

# print(typeof(result))
  return(result)
  
}