# DFW Senior Facilities Map

Interactive map of senior-living facilities in the Dallas-Fort Worth metroplex,
covering 634 licensed assisted-living facilities (Texas HHS registry) plus 39
senior activity centers, YMCAs, adult day care, and community senior programs.

Built with Leaflet, marker clustering, and a capacity-weighted heatmap layer.

## Features

- 8 color-coded categories (TYPE A / B / C, memory-care-heavy, activity centers, YMCAs, adult day, county/city programs)
- Layer toggles in the sidebar
- Heatmap toggle weighted by resident capacity
- Marker clustering at low zoom
- Hover tooltips and click popups with full facility info, including known Activity / Life Enrichment Director contacts
- Name search
- Mobile-friendly

## Live site

After GitHub Pages is enabled, the map will be available at:
`https://<your-github-username>.github.io/dfw-senior-map/`

## Data

- Source: Texas HHS Long-term Care Provider Search (assisted living licensees) plus a curated list of activity centers
- Geocoding: ZIP-centroid (street addresses shown in popups; click "Directions" for exact navigation in Google Maps)
- Last updated: see commit history
