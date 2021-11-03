FROM trestletech/plumber
WORKDIR /R/
COPY . .
EXPOSE 8000
RUN ["install2.r", "caret", "jsonlite"]
CMD ["/R/FSV_plumber_v4.R"]
