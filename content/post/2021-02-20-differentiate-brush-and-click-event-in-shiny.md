---
title: "Differentiate brush and click event in Shiny"
date: 2021-02-20
author: Zuguang Gu
---




I am recently developing a package
[**InteractiveComplexHeatmap**](https://github.com/jokergoo/InteractiveComplexHeatmap)
which generates interactive heatmaps as Shiny apps. One basic interactivity on
heatmap is to click on heatmap cells or to select a region from it. Shiny
allows to set `click` and `brush` arguments in `plotOutput()` to perform
clicking or brushing on the heatmap image, and on the server side, to respond
to these two actions. In **InteractiveComplexHeatmap**, I defined an action to
respond to click event and an action to respond to brush event. However, there is
one big problem that is brushing on heatmap is always intialized with a click
action, so when brushing on heatmap, both the response for click and brush
will be executed. This problem can be ignored by using `dbclick` (double
click) instead of `click`, but double click is not user-friendly.

I demonstrate this problem with the following app:


``` r
library(shiny)
library(grid)
library(glue)
library(circlize)

ui = fluidPage(
	plotOutput("plot", width = 600, height = 400,
		click = "click", brush = "brush"),
	
	fluidRow(
	    column(3, htmlOutput("output1")),
		column(3, htmlOutput("output2"))
	)
)

server = function(input, output, session) {
	output$plot = renderPlot({
		grid.newpage()
		grid.rect()
	})

	observeEvent(input$click, {
		output$output1 = renderText({
			isolate(glue("
<pre style='background-color:{rand_color(1)}'>
a click:
input$click$coords_css$x = {input$click$coords_css$x}
input$click$coords_css$y = {input$click$coords_css$y}</pre>"))
		})
	})


	observeEvent(input$brush, {
		output$output2 = renderText({
			isolate(glue("
<pre style='background-color:{rand_color(1)}'>
a brush:
input$brush$coords_css$xmin = {input$brush$coords_css$xmin}
input$brush$coords_css$ymin = {input$brush$coords_css$ymin}
input$brush$coords_css$xmax = {input$brush$coords_css$xmax}
input$brush$coords_css$ymax = {input$brush$coords_css$ymax}</pre>"))
		})
	})
}

shinyApp(ui, server)
```

The plot output only contains a rectangle. Both `click` and `brush`
are turned on. Clicking or brushing on the plot prints the coordinates.
The two output blocks (`output1` and `output2`) are assigned with
random colors to highlight different clicks or brushes.

As shown in following figure, every time when brushing on the plot,
the output for click also changes correspondingly. 

![](https://user-images.githubusercontent.com/449218/108605372-fe6f9d80-73b3-11eb-8192-03ceb8416aa5.gif)

Unfortunately, `plotOutput()` does not support to differentiate `click`
and `brush`, see https://stackoverflow.com/questions/30527977/ggplot2-how-to-differentiate-click-from-brush
and https://github.com/rstudio/shiny/issues/947.

After many tries, I figured out how to differentiate `click` and `brush`. The
idea is simple. In JavaScript, both click and brush contain two mouse events,
`mousedown` and `mouseup`. `mousedown` corresponds to the action when you
click into the mouse and `mouseup` corresponds to the action when you release
your finger. The difference between `click` and `brush` is `click` won't
change the mouse positions between `mousedown` and `mouseup`, while `brush`
changes. Once we can differentiate `click` and `brush`, when either of the two
actions finishes, we can create or update a reactive value by
`Shiny.setInputValue` in JaveScript to trigger the response in Shiny
server function.

I demonstrate this idea with the following code. When either of `click` or
`brush` finishes, the reactive variable `action` is created or updated 
by `Shiny.setInputValue('action', Math.random());`. In the server function,
we do not observe `input$click` or `input$brush` anymore, while now we
observe `input$action`. By comparing the positions of mouse, we can choose
whether to update click output or brush output.


``` r
library(shiny)
library(grid)
library(glue)
library(circlize)

ui = fluidPage(
	plotOutput("plot", width = 600, height = 400,
		click = "click", brush = "brush"),
	tags$script(HTML("
		$('#plot').mousedown(function(e) {
			var parentOffset = $(this).offset();
			var relX = e.pageX - parentOffset.left;
			var relY = e.pageY - parentOffset.top;
			Shiny.setInputValue('x1', relX);
			Shiny.setInputValue('y1', relY);
		}).mouseup(function(e) {
			var parentOffset = $(this).offset();
			var relX = e.pageX - parentOffset.left;
			var relY = e.pageY - parentOffset.top;
			Shiny.setInputValue('x2', relX);
			Shiny.setInputValue('y2', relY);
			Shiny.setInputValue('action', Math.random());
		});
	")),
	fluidRow(
	    column(3, htmlOutput("output1")),
		column(3, htmlOutput("output2"))
	)
)

server = function(input, output, session) {
	output$plot = renderPlot({
		grid.newpage()
		grid.rect()
	})

	observeEvent(input$action, {
		if(input$x1 == input$x2 && input$y1 == input$y2) {
			output$output1 = renderText({
				isolate(glue("
<pre style='background-color:{rand_color(1)}'>
a click:
x1 = {input$x1}
y1 = {input$y1}
x2 = {input$x2}
y2 = {input$y2}
input$click$coords_css$x = {input$click$coords_css$x}
input$click$coords_css$y = {input$click$coords_css$y}</pre>"))
			})
		} else {
			output$output2 = renderText({
				isolate(glue("
<pre style='background-color:{rand_color(1)}'>
a brush:
x1 = {input$x1}
y1 = {input$y1}
x2 = {input$x2}
y2 = {input$y2}
input$brush$coords_css$xmin = {input$brush$coords_css$xmin}
input$brush$coords_css$ymin = {input$brush$coords_css$ymin}
input$brush$coords_css$xmax = {input$brush$coords_css$xmax}
input$brush$coords_css$ymax = {input$brush$coords_css$ymax}</pre>"))
			})
		}
	})
}

shinyApp(ui, server)
```

As you can see the following figure, now the click and brush are independent. Brushing
on the plot won't conflict to the clicks.

![](https://user-images.githubusercontent.com/449218/108605376-00d1f780-73b4-11eb-97dd-271adf827562.gif)


Note, here the aim is to remove click event from brush, thus actually the code
for brush does not need to be changed (which means we still observe `output$brush`).
We can only observe `input$action` and respond to click only when the mouse
positions are unchanged (see how `observeEvent(input$action, ...)` is defined in following code).


``` r
ui = fluidPage(
	plotOutput("plot", width = 600, height = 400,
		click = "click", brush = "brush"),
	tags$script(HTML("
		$('#plot').mousedown(function(e) {
			var parentOffset = $(this).offset();
			var relX = e.pageX - parentOffset.left;
			var relY = e.pageY - parentOffset.top;
			Shiny.setInputValue('x1', relX);
			Shiny.setInputValue('y1', relY);
		}).mouseup(function(e) {
			var parentOffset = $(this).offset();
			var relX = e.pageX - parentOffset.left;
			var relY = e.pageY - parentOffset.top;
			Shiny.setInputValue('x2', relX);
			Shiny.setInputValue('y2', relY);
			Shiny.setInputValue('action', Math.random());
		});
	")),
	fluidRow(
	    column(3, htmlOutput("output1")),
		column(3, htmlOutput("output2"))
	)
)

server = function(input, output, session) {
	output$plot = renderPlot({
		grid.newpage()
		grid.rect()
	})

	observeEvent(input$action, {
		if(!(input$x1 == input$x2 && input$y1 == input$y2)) {
			return(NULL)
		}

		output$output1 = renderText({
			isolate(glue("
<pre style='background-color:{rand_color(1)}'>
a click:
input$click$coords_css$x = {input$click$coords_css$x}
input$click$coords_css$y = {input$click$coords_css$y}</pre>"))
		})
	})


	observeEvent(input$brush, {
		output$output2 = renderText({
			isolate(glue("
<pre style='background-color:{rand_color(1)}'>
a brush:
input$brush$coords_css$xmin = {input$brush$coords_css$xmin}
input$brush$coords_css$ymin = {input$brush$coords_css$ymin}
input$brush$coords_css$xmax = {input$brush$coords_css$xmax}
input$brush$coords_css$ymax = {input$brush$coords_css$ymax}</pre>"))
		})
	})
}
```
