abstract type AbstractItem end

function to_html(
    item::Tuple,
    x::Int
    )
    str =
    """
        <div class="cell small-12 medium-6">
            <h$x class="hx">$(item[1].first)</h$x>
            $(to_html(item[1].second))
        </div>
        <div class="cell small-12 medium-6">
            <h$x class="hx">$(item[2].first)</h$x>
            $(to_html(item[2].second))
        </div>
    """
end

function to_html(
    item::Pair,
    x::Int)
    str =
    """
    <h$x class="hx cell">$(item.first)</h$x>
    $(to_html(item.second))
    """
end

struct TextSection <: AbstractItem
    paragraphs::Vector{AbstractString}
    images::Vector{Pair{AbstractString,AbstractString}}
end

function to_html(section::TextSection)
    str =
    """
            <div class="cell medium-8 large-9">
    """

    for p in section.paragraphs
        str *=
        """
                    <p class="p-justify">$p</p>
        """
    end

    str *=
    """
    		</div>
    		<div class="cell medium-4 large-3 centered">
    """

    for img in section.images
        str *=
        """
                    <img class="thumbnail image hide-for-small-only" src="img/$(img.first)" alt="$(img.second)">
        """
    end

    str *=
    """
        </div>
    """
end

struct Card <: AbstractItem
    first::AbstractString
    second::AbstractString
    title::AbstractString
    content::AbstractString
end

function to_html(cards::Vector{Card})
    str =
    """
    <ul class="ul-card">
    """

    for c in cards
        str *=
        """
        <li>
            <div class="cardx">
                <span class="first any">$(c.first)</span>
                <span class="second any">$(c.second)</span>
            </div>
            <div class="description">
                <p class="cardtitle">$(c.title)</p>
                <p class="cardcontent">$(c.content)</p>
            </div>
        </li>
        """
    end

    str *=
    """
            </ul>
    """
end

struct TimeLine <: AbstractItem
    date::AbstractString
    content::AbstractString
    text::AbstractString
end

function to_html(timelines::Vector{TimeLine})
    str =
    """
    <ul class="timeline">
    """

    for tl in timelines
        str *=
        """
        <li>
            <div class="date">$(tl.date)</div>
            <div class="circle"></div>
            <div class="tldata">
                <div class="tlcontent">$(tl.content)</div>
                <div class="tltext">$(tl.text)</div>
            </div>
        </li>
        """
    end

    str *=
    """
            </ul>
    """
end

publication_labels = OrderedDict{AbstractString, ColorLabel}()

function to_html(publications::Vector{Bibliography.Publication})
    str = ""
    for p in publications
        bib = "files/" * p.id * ".bib"
        f = open("site/$bib", "w")
        write(f, p.cite)
        close(f)
        str *= 
        """
        <div class="publication cell">
            <div class="pub-contents">
                <div class="pubassets">
                    <a href="$(p.link)" class="tooltips"
                        title="" target="_blank" data-original-title="External link">
                        <i class="fas fa-external-link-alt"></i>
                    </a>
                    <a href="$(p.file)"
                        class="tooltips" title="" target="_blank" data-original-title="Download">
                        <i class="fas fa-scroll"></i>
                    </a>
                    <a href="$bib"
                        class="tooltips" title="" target="_blank" data-original-title="Cite">
                        <i class="fas fa-quote-left"></i>
                    </a>
                </div>
                <h4 class="pubtitle">$(p.title)</h4>
                <div class="pubcontents">
        """
        for label in p.labels
            if label ∉ keys(publication_labels)
                push!(publication_labels, label => ColorLabel(length(publication_labels)))
            end
            color = color_to_label[publication_labels[label]]
            str *=
            """
                        <span class="label $color">$(uppercasefirst(label))</span>
            """
        end

        str *=
        """
                    <div class="pubauthor">$(p.names)</div>
                    <div class="pubcite">$(p.in)</div>
                    <div class="pubyear">Publication year: $(p.year)</div>
                </div>
            </div>
        </div>
        """
    end
    return str
end

struct Bibtex
    source::AbstractString

    # function BibTeX(source::AbstractString)
    #     new(pwd() * "/" * source)
    # end
end

function BibTeX(source::AbstractString)
    BibTeX(pwd() * "/" * source)
end

function to_html(bib::Bibtex)
    println("bib: $(bib.source)")
    to_html(Bibliography.bibtex_to_web(bib.source))
end
