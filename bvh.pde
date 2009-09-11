//--------------------------------------------------------- -*- Mode: Java -*-
// $Id: bvh/bvh.pde $
//
// Created 2009-09-09
//----------------------------------------------------------------------------

import processing.opengl.*;

color randomColor()
{
    return color((int)random(50,255),
                 (int)random(50,255),
                 (int)random(50,255), 200);
}

float square(float x) { return x * x; }

PVector min(PVector a, PVector b)
{
    return new PVector(min(a.x, b.x),
                       min(a.y, b.y),
                       min(a.z, b.z));
}

PVector max(PVector a, PVector b)
{
    return new PVector(max(a.x, b.x),
                       max(a.y, b.y),
                       max(a.z, b.z));
}

PVector lerp(PVector a, PVector b, float t)
{
    return new PVector(
        lerp(a.x, b.x, t),
        lerp(a.y, b.y, t),
        lerp(a.z, b.z, t));
}

//----------------------------------------------------------------------------
// Box
//----------------------------------------------------------------------------
class Box
{
    PVector min;
    PVector max;

    Box()
    {
        clear();
    }

    void clear()
    {
        float INF = 1.0 / 0.0;
        this.min = new PVector( INF, INF, INF);
        this.max = new PVector(-INF,-INF,-INF);
    }

    void addPoint(PVector p)
    {
        this.min = min(this.min, p);
        this.max = max(this.max, p);
    }

    void addBox(Box b)
    {
        this.min = min(this.min, b.min);
        this.max = max(this.max, b.max);
    }
    
    void expand(float d)
    {
        this.min.sub(d,d,d);
        this.max.add(d,d,d);
    }

    PVector center()
    {
        PVector r = PVector.add(this.min, this.max);
        r.mult(0.5);
        return r;
    }
    
    PVector size()
    {
        return PVector.sub(this.max, this.min);
    }

    float radius()
    {
        return size().mag() * 0.5;
    }

    void draw(float scale)
    {
        PVector sz = size();
        PVector p = center();

        pushMatrix();
        translate(p.x, p.y, p.z);
        box(sz.x*scale, sz.y*scale, sz.z*scale);
        popMatrix();
    }

    void draw() { draw(1.0); }
};


//----------------------------------------------------------------------------
// BVH
//----------------------------------------------------------------------------
class BvhNode
{
    BvhNode up;
    BvhNode left;
    BvhNode right;
    
    Box bounds;

    void draw()
    {
        if(left != null)
        {
            fill(255,255,0,100);
            left.bounds.draw();
        }

        if(right != null)
        {
            fill(0,255,255,100);
            right.bounds.draw();
        }

        fill(255,0,255,64);
        bounds.draw(1.02);
    }
};


//----------------------------------------------------------------------------
// Setup
//----------------------------------------------------------------------------

PVector randomPoint()
{
    return new PVector(random(-100, 100),
                       random(-100, 100),
                       random(-100, 100));
}

Box randomBox()
{
    Box box = new Box();
    box.addPoint(randomPoint());
    box.expand(random(1,10));
    return box;
}

BvhNode buildRandomBvh()
{
    BvhNode nodes[] = new BvhNode[1024];
    for(int i = 0; i < nodes.length; ++i)
    {
        nodes[i] = new BvhNode();
        nodes[i].bounds = randomBox();
    }

    int count = nodes.length;
    while(count > 1)
    {
        int o = 0;
        int i = 0;
        while(i < count)
        {
            if(++i == count)
            {
                nodes[o++] = nodes[i-1];
                break;
            }
            
            BvhNode n = new BvhNode();
            n.left = nodes[i-1];
            n.right = nodes[i];
            n.left.up = n;
            n.right.up = n;
            n.bounds = new Box();
            n.bounds.addBox(n.left.bounds);
            n.bounds.addBox(n.right.bounds);

            nodes[o++] = n;
            ++i;
        }
        
        count = o;
    }

    return nodes[0];
}

BvhNode node = buildRandomBvh();
float heading = 0;
float pitch = radians(20);
float distance = 550;
PVector center = new PVector(0,0,0);

//----------------------------------------------------------------------------
// Processing
//----------------------------------------------------------------------------
void setup()
{
    size(600, 600, OPENGL);
}

void draw()
{
    resetMatrix();

    background(40);
    lights();

    Box box = node.bounds;

    distance = lerp(distance, box.radius() * 2.4, 0.1);
    center = lerp(center, box.center(), 0.1);

    beginCamera();
    resetMatrix();
    translate(center.x, center.y, center.z);
    rotateY(heading);
    rotateX(pitch);
    translate(0, 0, distance);
    endCamera();

    node.draw();
}

void mouseDragged()
{
    heading += (mouseX - pmouseX) * -0.01;
    pitch += (mouseY - pmouseY) * 0.01;
    pitch = constrain(pitch, -HALF_PI, HALF_PI);

    //redraw();
}

void keyTyped()
{
    if(key == 'a')
    {
        // left
        if(node.left != null)
            node = node.left;
    }
    else if(key == 'd')
    {
        // right
        if(node.right != null)
            node = node.right;
    }
    else if(key == 'w')
    {
        // up
        if(node.up != null)
            node = node.up;
    }
}
