function initSearch() {
  const searchForm = document.getElementById("search-form");
  let index = null;

  fetch("output/search-index.json").then(response => {
    if (!response.ok) {
      console.log("Failed to load search index");
      reset();
    }

    response.json().then(indexJson => {
      index = lunr.Index.load(indexJson)
      console.log("Loaded search index");
      showFlex(searchForm);
    })
  });

  const content = document.getElementById("content");
  const searchPanel = document.getElementById("search-panel");
  const backButton = searchPanel.querySelector("[data-action='hide-search']")

  searchForm.addEventListener("submit", doSearch);

  backButton.addEventListener("click", reset);

  function reset() {
    hide(searchPanel);
    showBlock(content);
  }

  function doSearch() {
    if (index === null) {
      return;
    }
    console.log('searchy time');
    hide(content);
    showBlock(searchPanel);
  }
}

function showBlock(elem) {
  elem.style.display = "block";
}

function showFlex(elem) {
  elem.style.display = "flex";
}

function hide(elem) {
  elem.style.display = "none";
}
