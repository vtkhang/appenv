# Session Architecture Overview

```mermaid
graph TB
    subgraph "Client"
        Browser["Browser"]
    end

    subgraph "Docker Environment"
        subgraph "Web Servers"
            PHP74["PHP 7.4<br/>:8074 / php74.localhost"]
            PHP82["PHP 8.2<br/>:8082 / php82.localhost"]
        end

        Redis[(Redis<br/>Session Storage<br/>:6379)]

        subgraph "Session Configuration"
            Cookie[".localhost domain<br/>SameSite: Lax<br/>HttpOnly: On"]
            Handler["save_handler: redis<br/>save_path: tcp://redis:6379"]
        end
    end

    Browser -->|Session Cookie| PHP74
    Browser -->|Session Cookie| PHP82
    PHP74 -->|Read/Write Sessions| Redis
    PHP82 -->|Read/Write Sessions| Redis
    Cookie -->|Shared across all .localhost| PHP74
    Cookie -->|Shared across all .localhost| PHP82
    Handler -->|Applied to both| PHP74
    Handler -->|Applied to both| PHP82

    style Redis fill:#ff6b6b
    style PHP74 fill:#4ecdc4
    style PHP82 fill:#4ecdc4
    style Browser fill:#ffe66d
```

## How It Works

1. **Centralized Session Storage**: Both PHP 7.4 and PHP 8.2 share a single Redis instance for session storage
2. **Cross-Subdomain Sharing**: Session cookies use `.localhost` domain, allowing sessions to persist across different subdomains (php74.localhost, php82.localhost)
3. **Cookie Configuration**: 
   - SameSite: Lax - Allows cross-subdomain navigation
   - HttpOnly: On - Improves security by preventing JavaScript access
4. **Shared Session Data**: Users can switch between PHP versions while maintaining the same session

## Benefits

- **Scalability**: Easy to add more PHP containers that share the same session storage
- **Version Testing**: Test the same session across different PHP versions
- **Session Persistence**: Sessions survive container restarts (Redis persists data)
- **Development Testing**: Test session behavior across different domains and ports
