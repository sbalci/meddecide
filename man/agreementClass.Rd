% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/agreement.b.R
\name{agreementClass}
\alias{agreementClass}
\title{Interrater Reliability Analysis}
\description{
Interrater reliability analysis including Cohen's kappa, Fleiss' kappa,
Krippendorff's alpha, and agreement visualization.
}
\section{Super classes}{
\code{\link[jmvcore:Analysis]{jmvcore::Analysis}} -> \code{meddecide::agreementBase} -> \code{agreementClass}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-agreementClass-clone}{\code{agreementClass$clone()}}
}
}
\if{html}{\out{
<details><summary>Inherited methods</summary>
<ul>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".createImage"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.createImage'><code>jmvcore::Analysis$.createImage()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".createImages"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.createImages'><code>jmvcore::Analysis$.createImages()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".createPlotObject"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.createPlotObject'><code>jmvcore::Analysis$.createPlotObject()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".load"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.load'><code>jmvcore::Analysis$.load()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".render"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.render'><code>jmvcore::Analysis$.render()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".save"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.save'><code>jmvcore::Analysis$.save()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".savePart"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.savePart'><code>jmvcore::Analysis$.savePart()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".setCheckpoint"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.setCheckpoint'><code>jmvcore::Analysis$.setCheckpoint()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".setParent"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.setParent'><code>jmvcore::Analysis$.setParent()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".setReadDatasetHeaderSource"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.setReadDatasetHeaderSource'><code>jmvcore::Analysis$.setReadDatasetHeaderSource()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".setReadDatasetSource"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.setReadDatasetSource'><code>jmvcore::Analysis$.setReadDatasetSource()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".setResourcesPathSource"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.setResourcesPathSource'><code>jmvcore::Analysis$.setResourcesPathSource()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id=".setStatePathSource"><a href='../../jmvcore/html/Analysis.html#method-Analysis-.setStatePathSource'><code>jmvcore::Analysis$.setStatePathSource()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="addAddon"><a href='../../jmvcore/html/Analysis.html#method-Analysis-addAddon'><code>jmvcore::Analysis$addAddon()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="asProtoBuf"><a href='../../jmvcore/html/Analysis.html#method-Analysis-asProtoBuf'><code>jmvcore::Analysis$asProtoBuf()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="asSource"><a href='../../jmvcore/html/Analysis.html#method-Analysis-asSource'><code>jmvcore::Analysis$asSource()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="check"><a href='../../jmvcore/html/Analysis.html#method-Analysis-check'><code>jmvcore::Analysis$check()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="init"><a href='../../jmvcore/html/Analysis.html#method-Analysis-init'><code>jmvcore::Analysis$init()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="optionsChangedHandler"><a href='../../jmvcore/html/Analysis.html#method-Analysis-optionsChangedHandler'><code>jmvcore::Analysis$optionsChangedHandler()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="postInit"><a href='../../jmvcore/html/Analysis.html#method-Analysis-postInit'><code>jmvcore::Analysis$postInit()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="print"><a href='../../jmvcore/html/Analysis.html#method-Analysis-print'><code>jmvcore::Analysis$print()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="readDataset"><a href='../../jmvcore/html/Analysis.html#method-Analysis-readDataset'><code>jmvcore::Analysis$readDataset()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="run"><a href='../../jmvcore/html/Analysis.html#method-Analysis-run'><code>jmvcore::Analysis$run()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="serialize"><a href='../../jmvcore/html/Analysis.html#method-Analysis-serialize'><code>jmvcore::Analysis$serialize()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="setError"><a href='../../jmvcore/html/Analysis.html#method-Analysis-setError'><code>jmvcore::Analysis$setError()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="setStatus"><a href='../../jmvcore/html/Analysis.html#method-Analysis-setStatus'><code>jmvcore::Analysis$setStatus()</code></a></span></li>
<li><span class="pkg-link" data-pkg="jmvcore" data-topic="Analysis" data-id="translate"><a href='../../jmvcore/html/Analysis.html#method-Analysis-translate'><code>jmvcore::Analysis$translate()</code></a></span></li>
<li><span class="pkg-link" data-pkg="meddecide" data-topic="agreementBase" data-id="initialize"><a href='../../meddecide/html/agreementBase.html#method-agreementBase-initialize'><code>meddecide::agreementBase$initialize()</code></a></span></li>
</ul>
</details>
}}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-agreementClass-clone"></a>}}
\if{latex}{\out{\hypertarget{method-agreementClass-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{agreementClass$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
