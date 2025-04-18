skip_on_cran()
skip_if_not_installed("curl")
skip_if_offline()
skip_if_not_installed("rstanarm")

data("pbcLong", package = "rstanarm")
m1 <- download_model("stanmvreg_1")
skip_if(is.null(m1))

test_that("clean_names", {
  expect_identical(
    clean_names(m1),
    c("logBili", "albumin", "year", "id", "sex")
  )
})

test_that("find_predictors", {
  expect_identical(
    find_predictors(m1),
    list(
      y1 = list(conditional = "year"),
      y2 = list(conditional = c("sex", "year"))
    )
  )
  expect_identical(find_predictors(m1, flatten = TRUE), c("year", "sex"))
  expect_identical(
    find_predictors(m1, effects = "all", component = "all"),
    list(
      y1 = list(conditional = "year", random = "id"),
      y2 = list(
        conditional = c("sex", "year"),
        random = "id"
      )
    )
  )
  expect_identical(
    find_predictors(
      m1,
      effects = "all",
      component = "all",
      flatten = TRUE
    ),
    c("year", "id", "sex")
  )
})

test_that("find_response", {
  expect_equal(
    find_response(m1, combine = TRUE),
    c(y1 = "logBili", y2 = "albumin")
  )
  expect_equal(
    find_response(m1, combine = FALSE),
    c(y1 = "logBili", y2 = "albumin")
  )
})

test_that("get_response", {
  expect_equal(nrow(get_response(m1)), 304)
  expect_equal(colnames(get_response(m1)), c("logBili", "albumin"))
})

test_that("find_statistic", {
  expect_null(find_statistic(m1))
})

test_that("find_variables", {
  expect_identical(
    find_variables(m1),
    list(
      response = c(y1 = "logBili", y2 = "albumin"),
      y1 = list(conditional = "year", random = "id"),
      y2 = list(
        conditional = c("sex", "year"),
        random = "id"
      )
    )
  )
  expect_identical(
    find_variables(m1, flatten = TRUE),
    c("logBili", "albumin", "year", "id", "sex")
  )
  expect_identical(
    find_variables(m1, effects = "random"),
    list(
      response = c(y1 = "logBili", y2 = "albumin"),
      y1 = list(random = "id"),
      y2 = list(random = "id")
    )
  )
})

test_that("find_terms", {
  expect_identical(
    find_terms(m1),
    list(
      y1 = list(
        response = "logBili",
        conditional = "year",
        random = "id"
      ),
      y2 = list(
        response = "albumin",
        conditional = c("sex", "year"),
        random = c("year", "id")
      )
    )
  )
  expect_identical(
    find_terms(m1, flatten = TRUE),
    c("logBili", "year", "id", "albumin", "sex")
  )
})

test_that("n_obs", {
  expect_equal(n_obs(m1), 304)
})

test_that("find_paramaters", {
  expect_equal(
    find_parameters(m1, component = "all"),
    structure(
      list(
        y1 = list(
          conditional = c("(Intercept)", "year"),
          random = sprintf("b[(Intercept) id:%i]", 1:40),
          sigma = "sigma"
        ),
        y2 = list(
          conditional = c("(Intercept)", "sexf", "year"),
          random = sprintf(
            c("b[(Intercept) id:%i]", "b[year id:%i]"),
            rep(1:40, each = 2)
          ),
          sigma = "sigma"
        )
      ),
      is_mv = "1"
    )
  )

  expect_equal(
    find_parameters(m1),
    structure(
      list(
        y1 = list(
          conditional = c("(Intercept)", "year"),
          random = sprintf("b[(Intercept) id:%i]", 1:40)
        ),
        y2 = list(
          conditional = c("(Intercept)", "sexf", "year"),
          random = sprintf(
            c("b[(Intercept) id:%i]", "b[year id:%i]"),
            rep(1:40, each = 2)
          )
        )
      ),
      is_mv = "1"
    )
  )

  expect_equal(
    find_parameters(m1, effects = "fixed", component = "all"),
    structure(
      list(
        y1 = list(
          conditional = c("(Intercept)", "year"),
          sigma = "sigma"
        ),
        y2 = list(
          conditional = c("(Intercept)", "sexf", "year"),
          sigma = "sigma"
        )
      ),
      is_mv = "1"
    )
  )

  expect_equal(
    find_parameters(m1, effects = "fixed"),
    structure(
      list(
        y1 = list(conditional = c("(Intercept)", "year")),
        y2 = list(conditional = c("(Intercept)", "sexf", "year"))
      ),
      is_mv = "1"
    )
  )

  expect_equal(
    find_parameters(m1, effects = "random", component = "all"),
    structure(
      list(
        y1 = list(random = sprintf("b[(Intercept) id:%i]", 1:40)),
        y2 = list(random = sprintf(
          c("b[(Intercept) id:%i]", "b[year id:%i]"),
          rep(1:40, each = 2)
        ))
      ),
      is_mv = "1"
    )
  )

  expect_equal(
    find_parameters(m1, effects = "random"),
    structure(
      list(
        y1 = list(random = sprintf("b[(Intercept) id:%i]", 1:40)),
        y2 = list(random = sprintf(
          c("b[(Intercept) id:%i]", "b[year id:%i]"),
          rep(1:40, each = 2)
        ))
      ),
      is_mv = "1"
    )
  )
})

test_that("get_parameters", {
  expect_equal(
    colnames(get_parameters(m1)),
    c(
      "y1|(Intercept)",
      "y1|year",
      "y2|(Intercept)",
      "y2|sexf",
      "y2|year"
    )
  )
  expect_equal(
    colnames(get_parameters(m1, effects = "all")),
    c(
      "y1|(Intercept)",
      "y1|year",
      sprintf("b[y1|(Intercept) id:%i]", 1:40),
      "y2|(Intercept)",
      "y2|sexf",
      "y2|year",
      sprintf(
        c("b[y2|(Intercept) id:%i]", "b[y2|year id:%i]"),
        rep(1:40, each = 2)
      )
    )
  )
})

test_that("linkfun", {
  expect_false(is.null(link_function(m1)))
  expect_length(link_function(m1), 2)
})

test_that("linkinv", {
  expect_false(is.null(link_inverse(m1)))
  expect_length(link_inverse(m1), 2)
})


test_that("is_multivariate", {
  expect_true(is_multivariate(m1))
})

test_that("clean_parameters", {
  expect_identical(
    clean_parameters(m1),
    structure(
      list(
        Parameter = c(
          "(Intercept)",
          "year",
          "(Intercept)",
          "sexf",
          "year",
          "b[(Intercept) id:1]",
          "b[(Intercept) id:2]",
          "b[(Intercept) id:3]",
          "b[(Intercept) id:4]",
          "b[(Intercept) id:5]",
          "b[(Intercept) id:6]",
          "b[(Intercept) id:7]",
          "b[(Intercept) id:8]",
          "b[(Intercept) id:9]",
          "b[(Intercept) id:10]",
          "b[(Intercept) id:11]",
          "b[(Intercept) id:12]",
          "b[(Intercept) id:13]",
          "b[(Intercept) id:14]",
          "b[(Intercept) id:15]",
          "b[(Intercept) id:16]",
          "b[(Intercept) id:17]",
          "b[(Intercept) id:18]",
          "b[(Intercept) id:19]",
          "b[(Intercept) id:20]",
          "b[(Intercept) id:21]",
          "b[(Intercept) id:22]",
          "b[(Intercept) id:23]",
          "b[(Intercept) id:24]",
          "b[(Intercept) id:25]",
          "b[(Intercept) id:26]",
          "b[(Intercept) id:27]",
          "b[(Intercept) id:28]",
          "b[(Intercept) id:29]",
          "b[(Intercept) id:30]",
          "b[(Intercept) id:31]",
          "b[(Intercept) id:32]",
          "b[(Intercept) id:33]",
          "b[(Intercept) id:34]",
          "b[(Intercept) id:35]",
          "b[(Intercept) id:36]",
          "b[(Intercept) id:37]",
          "b[(Intercept) id:38]",
          "b[(Intercept) id:39]",
          "b[(Intercept) id:40]",
          "b[(Intercept) id:1]",
          "b[year id:1]",
          "b[(Intercept) id:2]",
          "b[year id:2]",
          "b[(Intercept) id:3]",
          "b[year id:3]",
          "b[(Intercept) id:4]",
          "b[year id:4]",
          "b[(Intercept) id:5]",
          "b[year id:5]",
          "b[(Intercept) id:6]",
          "b[year id:6]",
          "b[(Intercept) id:7]",
          "b[year id:7]",
          "b[(Intercept) id:8]",
          "b[year id:8]",
          "b[(Intercept) id:9]",
          "b[year id:9]",
          "b[(Intercept) id:10]",
          "b[year id:10]",
          "b[(Intercept) id:11]",
          "b[year id:11]",
          "b[(Intercept) id:12]",
          "b[year id:12]",
          "b[(Intercept) id:13]",
          "b[year id:13]",
          "b[(Intercept) id:14]",
          "b[year id:14]",
          "b[(Intercept) id:15]",
          "b[year id:15]",
          "b[(Intercept) id:16]",
          "b[year id:16]",
          "b[(Intercept) id:17]",
          "b[year id:17]",
          "b[(Intercept) id:18]",
          "b[year id:18]",
          "b[(Intercept) id:19]",
          "b[year id:19]",
          "b[(Intercept) id:20]",
          "b[year id:20]",
          "b[(Intercept) id:21]",
          "b[year id:21]",
          "b[(Intercept) id:22]",
          "b[year id:22]",
          "b[(Intercept) id:23]",
          "b[year id:23]",
          "b[(Intercept) id:24]",
          "b[year id:24]",
          "b[(Intercept) id:25]",
          "b[year id:25]",
          "b[(Intercept) id:26]",
          "b[year id:26]",
          "b[(Intercept) id:27]",
          "b[year id:27]",
          "b[(Intercept) id:28]",
          "b[year id:28]",
          "b[(Intercept) id:29]",
          "b[year id:29]",
          "b[(Intercept) id:30]",
          "b[year id:30]",
          "b[(Intercept) id:31]",
          "b[year id:31]",
          "b[(Intercept) id:32]",
          "b[year id:32]",
          "b[(Intercept) id:33]",
          "b[year id:33]",
          "b[(Intercept) id:34]",
          "b[year id:34]",
          "b[(Intercept) id:35]",
          "b[year id:35]",
          "b[(Intercept) id:36]",
          "b[year id:36]",
          "b[(Intercept) id:37]",
          "b[year id:37]",
          "b[(Intercept) id:38]",
          "b[year id:38]",
          "b[(Intercept) id:39]",
          "b[year id:39]",
          "b[(Intercept) id:40]",
          "b[year id:40]",
          "sigma",
          "sigma"
        ),
        Effects = c(
          "fixed",
          "fixed",
          "fixed",
          "fixed",
          "fixed",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "random",
          "fixed",
          "fixed"
        ),
        Component = c(
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "conditional",
          "sigma",
          "sigma"
        ),
        Group = c(
          "",
          "",
          "",
          "",
          "",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "Intercept: id",
          "year: id",
          "",
          ""
        ),
        Response = c(
          "y1",
          "y1",
          "y2",
          "y2",
          "y2",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y1",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y2",
          "y1",
          "y2"
        ),
        Cleaned_Parameter = c(
          "(Intercept)",
          "year",
          "(Intercept)",
          "sexf",
          "year",
          "id:1",
          "id:2",
          "id:3",
          "id:4",
          "id:5",
          "id:6",
          "id:7",
          "id:8",
          "id:9",
          "id:10",
          "id:11",
          "id:12",
          "id:13",
          "id:14",
          "id:15",
          "id:16",
          "id:17",
          "id:18",
          "id:19",
          "id:20",
          "id:21",
          "id:22",
          "id:23",
          "id:24",
          "id:25",
          "id:26",
          "id:27",
          "id:28",
          "id:29",
          "id:30",
          "id:31",
          "id:32",
          "id:33",
          "id:34",
          "id:35",
          "id:36",
          "id:37",
          "id:38",
          "id:39",
          "id:40",
          "id:1",
          "id:1",
          "id:2",
          "id:2",
          "id:3",
          "id:3",
          "id:4",
          "id:4",
          "id:5",
          "id:5",
          "id:6",
          "id:6",
          "id:7",
          "id:7",
          "id:8",
          "id:8",
          "id:9",
          "id:9",
          "id:10",
          "id:10",
          "id:11",
          "id:11",
          "id:12",
          "id:12",
          "id:13",
          "id:13",
          "id:14",
          "id:14",
          "id:15",
          "id:15",
          "id:16",
          "id:16",
          "id:17",
          "id:17",
          "id:18",
          "id:18",
          "id:19",
          "id:19",
          "id:20",
          "id:20",
          "id:21",
          "id:21",
          "id:22",
          "id:22",
          "id:23",
          "id:23",
          "id:24",
          "id:24",
          "id:25",
          "id:25",
          "id:26",
          "id:26",
          "id:27",
          "id:27",
          "id:28",
          "id:28",
          "id:29",
          "id:29",
          "id:30",
          "id:30",
          "id:31",
          "id:31",
          "id:32",
          "id:32",
          "id:33",
          "id:33",
          "id:34",
          "id:34",
          "id:35",
          "id:35",
          "id:36",
          "id:36",
          "id:37",
          "id:37",
          "id:38",
          "id:38",
          "id:39",
          "id:39",
          "id:40",
          "id:40",
          "sigma",
          "sigma"
        )
      ),
      class = c("clean_parameters", "data.frame"),
      row.names = c(NA, -127L)
    )
  )
})
